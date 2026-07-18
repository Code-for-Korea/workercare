class DiseaseCasesController < ApplicationController
  MAX_SEARCH_RESULTS = 500

  # 기존 /search (이전에는 root)
  def index
    perform_search(legacy: true)
  end

  # 신규 / (메인 화면)
  def main
    perform_search(legacy: false)
    @burden_body_part_options = burden_body_part_options
    @application_type_options = application_type_options
  end

  def show
    @disease_case = DiseaseCase.find_by(case_no: params[:case_no])
  end

  private

  def perform_search(legacy:)
    @scope, @fallback = legacy ? DiseaseCase.search(search_params) : DiseaseCase.main_search(main_search_params)
    @pagy, @cases = paginate(@scope)
    @cases = @cases.includes(:ksco_codes) unless legacy
    @metadata = build_metadata

    log_search_event
  end

  # burden_body_part는 파이프(|) 구분 다중값 텍스트이므로, 체크박스 후보 목록은 저장된 값을
  # split해서 만든다 (사전 정의된 enum이 아님 — 3.2절 참고).
  def burden_body_part_options
    DiseaseCase.where.not(burden_body_part: [ nil, "" ])
      .distinct.pluck(:burden_body_part)
      .flat_map { |v| v.split("|") }
      .map(&:strip).reject(&:blank?).uniq.sort
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
