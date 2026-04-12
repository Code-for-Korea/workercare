class SearchesController < ApplicationController
  def index
    @search = DiseaseCaseSearch.new(search_params)
    @over_cap, @result_count, results = @search.capped_results
    @pagy, @cases = pagy_array(results)

    log_search(results)
  end

  def search
    @search = DiseaseCaseSearch.new(search_params)
    @over_cap, @result_count, results = @search.capped_results
    @pagy, @cases = pagy_array(results)

    log_search(results)
  end

  private

  def search_params
    params.permit(:q, :result, :year, :disease_category, :body_part, :decided_on_from, :decided_on_to, :sort)
  end

  def log_search(results)
    Rails.logger.info({
      event: "search",
      query: @search.raw_query,
      result_count: @result_count,
      over_cap: @over_cap,
      used_fallback: @search.fallback?
    }.to_json)
  end
end
