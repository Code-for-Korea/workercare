class DiseaseCasesController < ApplicationController
  MAX_SEARCH_RESULTS = 500

  def index
    perform_search
  end

  def show
    @disease_case = DiseaseCase.find_by(case_no: params[:case_no])
  end

  private

  def perform_search
    @scope, @fallback = DiseaseCase.search(search_params)
    @pagy, @cases = paginate(@scope)
    @metadata = build_metadata

    log_search_event
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
    params.permit(:q, :result, :year, :disease_category, :body_part, :decided_on_from, :decided_on_to, :sort, :commit)
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
