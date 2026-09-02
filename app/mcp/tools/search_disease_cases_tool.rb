# frozen_string_literal: true

class SearchDiseaseCasesTool < ApplicationMCPTool
  tool_name "search_disease_cases"
  title "Search Disease Cases"
  description "Search occupational disease determination cases from the database with statistics and confidence scoring."
  read_only
  open_world false

  property :q,
           type: "string",
           description: "Natural language search query extracted from user question. Optional — " \
             "omit it to search using only the structured filters below (e.g. death_status, ksco_code, job_name).",
           required: false

  collection :search_in,
             type: "string",
             description: "Columns to search in. Allowed: application_content, applicant_claim, medical_records, recognized_facts, committee_decision. Defaults to all.",
             required: false

  collection :disease_category,
             type: "string",
             description: "Filter by disease category. Allowed: musculoskeletal, other_disease, hearing_loss, cardiovascular, cancer, pneumoconiosis, respiratory",
             required: false

  collection :body_part,
             type: "string",
             description: "Filter by body part. Allowed: chest_back, ear, other, eye, leg, head, neck, foot, abdomen, multiple, urogenital, digestive, hand, circulatory, nervous_system, face, hip, whole_body, arm, lower_back, respiratory_organ",
             required: false

  property :decided_on_from,
           type: "string",
           description: "Start date filter (YYYY-MM-DD)",
           required: false

  property :decided_on_to,
           type: "string",
           description: "End date filter (YYYY-MM-DD)",
           required: false

  property :limit,
           type: "number",
           description: "Maximum number of cases to return in the cases array. Statistics always use the full matching set.",
           required: false,
           default: 10

  property :job_name,
           type: "string",
           description: "Filter by job title/occupation (partial match), e.g. '버스 운전원'",
           required: false

  property :job_description,
           type: "string",
           description: "Filter by job duty description (partial match)",
           required: false

  property :death_status,
           type: "string",
           description: "Filter by whether the case involved a death. Allowed: Y, N",
           required: false

  collection :ksco_code,
             type: "string",
             description: "Filter by KSCO (Korean Standard Classification of Occupations) code(s), e.g. 8722",
             required: false

  def perform
    if q.blank? && no_structured_filters?
      return render structured: {
        error: "q(검색어) 또는 구조화 필터(job_name/job_description/death_status/ksco_code/" \
          "disease_category/body_part/decided_on_from/decided_on_to) 중 최소 하나는 지정해야 합니다.",
        data: nil
      }
    end

    search_params = build_search_params
    scope, fallback = DiseaseCase.search(search_params)
    scope = DiseaseCase.apply_main_filters(scope, main_filter_params)
    total_count = scope.count

    if total_count.zero?
      return render structured: {
        error: nil,
        data: {
          total_count: 0,
          confidence_score: 0.0,
          confidence_reason: "일치하는 사례를 찾지 못했습니다.",
          used_fallback: fallback,
          cases: [],
          statistics: empty_statistics
        }
      }
    end

    statistics = build_statistics(scope)
    limited_scope = scope.limit(limit.presence || 10)
    cases_data = build_cases(limited_scope)
    confidence = calculate_confidence(cases_data, fallback)

    render structured: {
      error: nil,
      data: {
        total_count: total_count,
        confidence_score: confidence[:score],
        confidence_reason: confidence[:reason],
        used_fallback: fallback,
        cases: cases_data,
        statistics: statistics
      }
    }
  rescue ArgumentError => e
    render structured: {
      error: e.message,
      data: nil
    }
  rescue => e
    Rails.logger.error("[SearchDiseaseCasesTool] #{e.class}: #{e.message}")
    render structured: {
      error: "검색 서비스에 일시적인 문제가 발생했습니다. 잠시 후 다시 시도해주세요.",
      data: nil
    }
  end

  private

  # q도 없고 구조화 필터도 하나도 없으면 DiseaseCase.search(q: nil)가 스코프 필터 없이 전체
  # 코퍼스(6만여 건)를 반환한다 — LLM이 사용자 발화에서 필터를 하나도 못 뽑아낸 경우 이걸
  # 유효한 검색 결과인 것처럼 confidence_score까지 붙여 내보내는 회귀가 있었다(코드 리뷰에서
  # 발견·재현 확인). limit은 필터가 아니라 페이지네이션 옵션이라 여기서 세지 않는다.
  def no_structured_filters?
    Array(search_in).reject(&:blank?).empty? &&
      Array(disease_category).reject(&:blank?).empty? &&
      Array(body_part).reject(&:blank?).empty? &&
      decided_on_from.blank? && decided_on_to.blank? &&
      job_name.blank? && job_description.blank? &&
      death_status.blank? && Array(ksco_code).reject(&:blank?).empty?
  end

  def build_search_params
    params = { q: q }
    params[:search_in] = Array(search_in).reject(&:blank?) if search_in.present?
    params[:disease_category] = Array(disease_category).reject(&:blank?) if disease_category.present?
    params[:body_part] = Array(body_part).reject(&:blank?) if body_part.present?
    params[:decided_on_from] = parse_date(decided_on_from) if decided_on_from.present?
    params[:decided_on_to] = parse_date(decided_on_to) if decided_on_to.present?
    params
  end

  def parse_date(value)
    Date.parse(value)
  rescue Date::Error
    raise ArgumentError, "날짜 형식이 올바르지 않습니다. YYYY-MM-DD 형식으로 입력해주세요."
  end

  def main_filter_params
    params = {}
    params[:job_name] = job_name if job_name.present?
    params[:job_description] = job_description if job_description.present?
    params[:death_status] = death_status if death_status.present?
    params[:ksco_code] = Array(ksco_code).reject(&:blank?) if ksco_code.present?
    params
  end

  def build_statistics(scope)
    # scope에 걸려있는 ORDER BY bm25(...)는 GROUP BY 집계와 함께 쓰면 SQLite가
    # "unable to use function bm25 in the requested context"를 던진다. 집계 결과는 정렬과
    # 무관하므로 order를 제거하고 집계한다.
    counts = scope.reorder(nil).group(:result).count

    approved = counts["approved"] || 0
    rejected = counts["rejected"] || 0
    partially_approved = counts["partially_approved"] || 0
    revised_approved = counts["revised_approved"] || 0
    total = approved + rejected + partially_approved + revised_approved

    return empty_statistics if total.zero?

    {
      approved: approved,
      rejected: rejected,
      partially_approved: partially_approved,
      revised_approved: revised_approved,
      total: total,
      approval_rate: format_rate(approved.to_f / total),
      rejection_rate: format_rate(rejected.to_f / total),
      substantive_approval_rate: format_rate((approved + partially_approved + revised_approved).to_f / total),
      strict_approval_rate: format_rate(approved.to_f / total)
    }
  end

  def empty_statistics
    {
      approved: 0,
      rejected: 0,
      partially_approved: 0,
      revised_approved: 0,
      total: 0,
      approval_rate: "0.0%",
      rejection_rate: "0.0%",
      substantive_approval_rate: "0.0%",
      strict_approval_rate: "0.0%"
    }
  end

  def format_rate(value)
    "#{(value * 100).round(1)}%"
  end

  def build_cases(scope)
    scope.map do |c|
      {
        case_no: c.case_no,
        disease_name: c.disease_name.presence || "미상",
        result: c.result,
        result_label: result_label(c.result),
        year: c.year,
        job_name: c.job_name,
        death_status: c.death_status,
        summary: truncate(c.applicant_claim, 300),
        key_facts: truncate(c.recognized_facts, 300),
        decision_excerpt: truncate(c.committee_decision, 300),
        match_reason: build_match_reason(c)
      }
    end
  end

  def result_label(result)
    {
      "approved" => "인정",
      "rejected" => "불인정",
      "partially_approved" => "일부인정",
      "revised_approved" => "정정인정"
    }[result] || result
  end

  # job_name/job_description/death_status/ksco_code는 apply_main_filters로 이미 WHERE 조건에
  # 반영되어 있으므로, 여기서는 "그 필터가 지정되었는가"만 확인하면 된다 (반환된 case는 이미 매칭된
  # 것이 보장됨). 자유 텍스트 키워드를 work_keywords/symptom_keywords 사전과 비교하던 기존
  # work_match?/symptom_match? ad-hoc 로직은 구조화 필터로 대체한다.
  def build_match_reason(disease_case)
    reasons = []
    reasons << "동일 신체부위" if body_part_match?(disease_case)
    reasons << "동일 질병" if disease_match?(disease_case)
    reasons << "동일 직종" if job_name.present?
    reasons << "동일 사망 여부" if death_status.present?
    reasons.map { |r| { reason: r } }
  end

  def body_part_match?(disease_case)
    Array(body_part).any? { |bp| disease_case.body_part == bp }
  end

  def disease_match?(disease_case)
    Array(disease_category).any? { |dc| disease_case.disease_category == dc }
  end

  def calculate_confidence(cases_data, fallback)
    total = cases_data.size
    return { score: 0.0, reason: "검색 결과가 없습니다." } if total.zero?

    body_part_matches = cases_data.count { |c| c[:match_reason].any? { |r| r[:reason] == "동일 신체부위" } }
    disease_matches = cases_data.count { |c| c[:match_reason].any? { |r| r[:reason] == "동일 질병" } }
    job_name_matches = cases_data.count { |c| c[:match_reason].any? { |r| r[:reason] == "동일 직종" } }

    score = 0.5
    score += 0.2 if body_part_matches > 0
    score += 0.2 if disease_matches > 0
    score += 0.1 if job_name_matches > 0
    score -= 0.1 if fallback
    score = [ [ score, 0.0 ].max, 1.0 ].min

    reason_parts = []
    reason_parts << "유사 사례 #{total}건"
    reason_parts << "동일 신체부위 #{body_part_matches}건" if body_part_matches > 0
    reason_parts << "동일 질병분류 #{disease_matches}건" if disease_matches > 0
    reason_parts << "동일 직종 #{job_name_matches}건" if job_name_matches > 0
    reason_parts << "(substring fallback 사용)" if fallback

    { score: score.round(2), reason: reason_parts.join(", ") }
  end

  def truncate(text, max_length)
    return "" if text.blank?
    text.length > max_length ? "#{text[0...max_length]}..." : text
  end
end
