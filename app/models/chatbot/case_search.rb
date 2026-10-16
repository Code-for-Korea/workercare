# frozen_string_literal: true

module Chatbot
  # 정규화된 조건으로 DiseaseCase.main_search를 호출하고 공개 DTO로 변환한다.
  # 매핑(project-plan §6): disease_name/job_name/result는 구조화 필터, work_factor는 q(FTS).
  class CaseSearch
    # 한 번에 보여 주는 사례 수. listCard 5건 × 2장 = 10건이 한 응답(outputs 3개)의 한도다.
    PAGE_SIZE = 10
    # 웹 검색(DiseaseCasesController::MAX_SEARCH_RESULTS)과 같은 상한. 도달하면 정확한 건수를 숨긴다.
    COUNT_CAP = 500

    Result = Struct.new(:cases, :total_count, :over_cap, :used_fallback, :has_more, :page, keyword_init: true)

    def initialize(conditions, page:, base_url:)
      @conditions = conditions
      @page = page
      @base_url = base_url
    end

    def call
      scope, fallback = DiseaseCase.main_search(search_params)
      count = scope.except(:order).limit(COUNT_CAP).count
      over_cap = count >= COUNT_CAP
      offset = @page * PAGE_SIZE
      records = scope.offset(offset).limit(PAGE_SIZE).to_a

      Result.new(
        cases: records.map { |record| PublicCase.new(record, base_url: @base_url) },
        total_count: over_cap ? nil : count,
        over_cap: over_cap,
        used_fallback: fallback,
        has_more: offset + records.size < count,
        page: @page
      )
    end

    private

    def search_params
      {
        disease_name: @conditions.disease_name,
        job_name: @conditions.job_name,
        q: @conditions.work_factor,
        result: @conditions.result
      }.compact
    end
  end
end
