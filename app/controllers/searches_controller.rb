class SearchesController < ApplicationController
  MAX_SEARCH_RESULTS = 500

  def index
    @scope, @fallback = DiseaseCase.search(search_params)
    @pagy, @cases = pagy(@scope, items: 12, max_items: MAX_SEARCH_RESULTS)

    @over_cap = @pagy.count >= MAX_SEARCH_RESULTS
    @result_count = @over_cap ? nil : @pagy.count

    log_search
  end

  def search
    @scope, @fallback = DiseaseCase.search(search_params)
    @pagy, @cases = pagy(@scope, items: 12, max_items: MAX_SEARCH_RESULTS)

    @over_cap = @pagy.count >= MAX_SEARCH_RESULTS
    @result_count = @over_cap ? nil : @pagy.count

    log_search
  end

  private

  def search_params
    params.permit(:q, :result, :year, :disease_category, :body_part, :decided_on_from, :decided_on_to, :sort)
  end

  def log_search
    Rails.logger.info({
      event: "search",
      query: params[:q],
      result_count: @result_count,
      over_cap: @over_cap,
      used_fallback: @fallback
    }.to_json)
  end
end
