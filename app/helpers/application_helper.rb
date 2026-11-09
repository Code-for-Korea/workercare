module ApplicationHelper
  # 검색 화면의 필터 묶음을 펼쳐 둘지: 검색어·정렬·쪽 말고 값이 있는 조건이 하나라도 있으면 true.
  SEARCH_NON_FILTER_PARAMS = %w[q sort page search commit].freeze

  def search_filters_open?
    request.query_parameters.any? do |key, value|
      SEARCH_NON_FILTER_PARAMS.exclude?(key) && Array(value).any?(&:present?)
    end
  end

  def years_for_select
    current_year = Date.today.year
    (2000..current_year).to_a.reverse.map { |y| [ y.to_s, y.to_s ] }
  end

  def years_for_select_with_blank
    [ [ "— #{t("search.all_results")} —", "" ] ] + years_for_select
  end
end
