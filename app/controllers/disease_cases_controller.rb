class DiseaseCasesController < ApplicationController
  MAX_SEARCH_RESULTS = 500
  BURDEN_BODY_PART_CHECKBOX_LIMIT = 12
  # wip/cerebras_prompts.rb 추출 스키마상 허용값 6개 전부 (docs/workercare-search.plan.md 3.2절) —
  # DB에도 이 6개만 존재하는 진짜 enum이라 distinct pluck 대신 고정 목록을 순서대로 노출한다.
  WORK_RELEVANCE_EVAL_OPTIONS = %w[매우_높음 높음 보통 낮음 매우_낮음 미흡].freeze

  # / (메인 화면). 간단한 검색을 위해 직업·부담 신체 부위·사망 여부·신청서 유형만 노출한다 —
  # 고용형태/근무형태/업무관련성/KSCO 코드는 /search(상세 검색)에서만 노출한다.
  def index
    perform_search(legacy: false)
    set_common_filter_options
  end

  # /search (상세 검색, 이전에는 root였다). 메인 화면 필터도 함께 쓸 수 있도록
  # apply_main_filters를 추가로 적용한다.
  def search
    perform_search(legacy: true)
    set_common_filter_options
    set_advanced_filter_options
  end

  def show
    @disease_case = DiseaseCase.find_by(case_no: params[:case_no])
  end

  private

  def perform_search(legacy:)
    if legacy
      @scope, @fallback = DiseaseCase.search(search_params)
      @scope = DiseaseCase.apply_main_filters(@scope, main_search_params)
    else
      @scope, @fallback = DiseaseCase.main_search(main_search_params)
    end
    @pagy, @cases = paginate(@scope)
    @metadata = build_metadata

    log_search_event
  end

  def set_common_filter_options
    counts = burden_body_part_token_counts
    @burden_body_part_options = burden_body_part_options(counts)
    @burden_body_part_datalist_options = burden_body_part_datalist_options(counts)
    @application_type_options = application_type_options
  end

  def set_advanced_filter_options
    @employment_type_options = employment_type_options
    @work_relevance_eval_options = WORK_RELEVANCE_EVAL_OPTIONS
    @ksco_code_options = ksco_code_options
  end

  # burden_body_part는 파이프(|) 구분 다중값 텍스트이며 실 데이터 기준 distinct 토큰이
  # 1,000개를 넘는 자유 텍스트라(사전 정의된 enum이 아님 — 3.2절 참고), 체크박스로는
  # 자주 쓰는 상위 N개만 노출하고 나머지는 <datalist> 자동완성 텍스트 입력으로 찾는다.
  def burden_body_part_token_counts
    counts = Hash.new(0)
    DiseaseCase.where.not(burden_body_part: [ nil, "" ]).pluck(:burden_body_part).each do |raw|
      raw.split("|").each { |token| counts[token.strip] += 1 unless token.strip.blank? }
    end
    counts
  end

  def burden_body_part_options(counts)
    counts.sort_by { |_, count| -count }
      .first(BURDEN_BODY_PART_CHECKBOX_LIMIT).map(&:first).sort
  end

  def burden_body_part_datalist_options(counts)
    counts.keys.sort
  end

  def application_type_options
    DiseaseCase.where.not(application_type: [ nil, "" ]).distinct.order(:application_type).pluck(:application_type)
  end

  # employment_type도 distinct 값이 1,583개로 많지만(예: "1년 계약직"/"1년 계약직(비정규직)"),
  # burden_body_part_text와 같은 <datalist> 자동완성으로 노출한다 — 사용자가 목록에서 골라 제출하므로
  # apply_main_filters의 exact match(where(employment_type: ...))가 항상 그대로 맞는다.
  def employment_type_options
    DiseaseCase.where.not(employment_type: [ nil, "" ]).distinct.order(:employment_type).pluck(:employment_type)
  end

  # KscoCode는 CSV 기준 500여 개뿐이라(wip/ksco-level-4-details.csv) <datalist> 전체 노출이 가능하다.
  # 계층형(대분류→세분류) 자동완성 UI는 1.3절 열린 질문대로 2차 구현으로 남겨두고, 우선 코드 하나를
  # 직접 검색해 고르는 최소 UI만 제공한다.
  def ksco_code_options
    KscoCode.order(:code).pluck(:code, :name)
  end

  def paginate(scope)
    pagy(scope, items: 12, max_items: MAX_SEARCH_RESULTS)
  end

  def build_metadata
    over_cap = @pagy.count >= MAX_SEARCH_RESULTS

    {
      total_count: over_cap ? nil : @pagy.count,
      over_cap: over_cap,
      used_fallback: @fallback
    }
  end

  def search_params
    params.permit(:q, :result, :year, :decided_on_from, :decided_on_to, :sort, :commit, :search, search_in: [], disease_category: [], body_part: [])
  end

  def main_search_params
    params.permit(
      :q, :job_name, :job_description,
      :death_status, :application_type, :employment_type, :work_type,
      :work_relevance_eval, :sort, :commit, :search,
      :burden_body_part_text,
      burden_body_part: [], ksco_code: []
    )
  end

  def log_search_event
    Rails.logger.info({
      event: "search",
      query: params[:q],
      result_count: @metadata[:total_count],
      over_cap: @metadata[:over_cap],
      used_fallback: @fallback
    }.to_json)
  end
end
