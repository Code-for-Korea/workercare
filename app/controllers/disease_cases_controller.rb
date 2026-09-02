class DiseaseCasesController < ApplicationController
  MAX_SEARCH_RESULTS = 500
  BURDEN_BODY_PART_CHECKBOX_LIMIT = 12

  # 기존 /search (이전에는 root). 메인 화면(직업·부담 신체 부위·사망 여부·신청서 유형) 필터도
  # 함께 쓸 수 있도록 apply_main_filters를 추가로 적용한다.
  def index
    perform_search(legacy: true)
    set_main_filter_options
  end

  # 신규 / (메인 화면)
  def main
    perform_search(legacy: false)
    set_main_filter_options
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

  def set_main_filter_options
    counts = burden_body_part_token_counts
    @burden_body_part_options = burden_body_part_options(counts)
    @burden_body_part_datalist_options = burden_body_part_datalist_options(counts)
    @application_type_options = application_type_options
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
