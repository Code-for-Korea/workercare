# frozen_string_literal: true

class SearchDiseaseCasesTool < ApplicationMCPTool
  tool_name "search_disease_cases"
  description "Search occupational disease determination cases from the database with statistics and confidence scoring."

  property :q,
           type: "string",
           description: "Natural language search query extracted from user question",
           required: true

  property :search_in,
           type: "array",
           description: "Columns to search in. Allowed: application_content, applicant_claim, medical_records, recognized_facts, committee_decision. Defaults to all.",
           required: false

  property :disease_category,
           type: "array",
           description: "Filter by disease category. Allowed: musculoskeletal, other_disease, hearing_loss, cardiovascular, cancer, pneumoconiosis, respiratory",
           required: false

  property :body_part,
           type: "array",
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

  output_schema do
    property :error, type: "string", required: false
    property :data, type: "object", required: false do
      property :total_count, type: "number", required: true
      property :confidence_score, type: "number", required: true
      property :confidence_reason, type: "string", required: true
      property :used_fallback, type: "boolean", required: true

      array :cases do
        object :case do
          property :case_no, type: "string", required: true
          property :disease_name, type: "string", required: true
          property :result, type: "string", required: true
          property :result_label, type: "string", required: true
          property :year, type: "number", required: true
          property :summary, type: "string", required: true
          property :key_facts, type: "string", required: true
          property :decision_excerpt, type: "string", required: true
          array :match_reason do
            property :reason, type: "string"
          end
        end
      end

      object :statistics do
        property :approved, type: "number", required: true
        property :rejected, type: "number", required: true
        property :partially_approved, type: "number", required: true
        property :revised_approved, type: "number", required: true
        property :total, type: "number", required: true
        property :approval_rate, type: "string", required: true
        property :rejection_rate, type: "string", required: true
        property :substantive_approval_rate, type: "string", required: true
        property :strict_approval_rate, type: "string", required: true
      end
    end
  end

  def perform
    search_params = build_search_params
    scope, fallback = DiseaseCase.search(search_params)
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

  def build_statistics(scope)
    counts = scope.group(:result).count

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

  def build_match_reason(disease_case)
    reasons = []
    reasons << "동일 신체부위" if body_part_match?(disease_case)
    reasons << "유사 업무" if work_match?(disease_case)
    reasons << "유사 증상" if symptom_match?(disease_case)
    reasons << "동일 질병" if disease_match?(disease_case)
    reasons.map { |r| { reason: r } }
  end

  def body_part_match?(disease_case)
    Array(body_part).any? { |bp| disease_case.body_part == bp }
  end

  def work_match?(disease_case)
    query_tokens = q.to_s.split(" ").map { |t| t.gsub(/은|는|이|가|을|를|의$/, "") }
    work_keywords = %w[사무실 컴퓨터 공장 건설 운전 반복 야간 교대]
    query_tokens.any? { |token| work_keywords.any? { |kw| token.include?(kw) } }
  end

  def symptom_match?(disease_case)
    query_tokens = q.to_s.split(" ").map { |t| t.gsub(/은|는|이|가|을|를|의$/, "") }
    symptom_keywords = %w[아픔 통증 저림 불편 마비 어지러움]
    query_tokens.any? { |token| symptom_keywords.any? { |kw| token.include?(kw) } }
  end

  def disease_match?(disease_case)
    Array(disease_category).any? { |dc| disease_case.disease_category == dc }
  end

  def calculate_confidence(cases_data, fallback)
    total = cases_data.size
    return { score: 0.0, reason: "검색 결과가 없습니다." } if total.zero?

    body_part_matches = cases_data.count { |c| c[:match_reason].any? { |r| r[:reason] == "동일 신체부위" } }
    disease_matches = cases_data.count { |c| c[:match_reason].any? { |r| r[:reason] == "동일 질병" } }

    score = 0.5
    score += 0.2 if body_part_matches > 0
    score += 0.2 if disease_matches > 0
    score -= 0.1 if fallback
    score = [[score, 0.0].max, 1.0].min

    reason_parts = []
    reason_parts << "유사 사례 #{total}건"
    reason_parts << "동일 신체부위 #{body_part_matches}건" if body_part_matches > 0
    reason_parts << "동일 질병분류 #{disease_matches}건" if disease_matches > 0
    reason_parts << "(substring fallback 사용)" if fallback

    { score: score.round(2), reason: reason_parts.join(", ") }
  end

  def truncate(text, max_length)
    return "" if text.blank?
    text.length > max_length ? "#{text[0...max_length]}..." : text
  end
end
