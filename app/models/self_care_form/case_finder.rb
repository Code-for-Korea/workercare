# frozen_string_literal: true

module SelfCareForm
  # 고른 조건으로 비슷한 판정 사례를 찾고, 0건이면 약한 조건부터 하나씩 뺀다.
  #
  # 완화 사다리(앞에서 뒤로): 모든 조건 → 판정 결과 조건 제거(고른 경우만) → 직업 조건 제거. 신체부위는 끝까지 유지한다.
  # SQL 횟수: 시도 한 번 = 목록 1회(limit 11, 비면 다음 시도). 처음 비어 있지 않은 시도에서만 건수 1회를 더한다.
  # 그래서 시도 수(최대 3) + 1회 이하다. `q`는 쓰지 않는다(main_search가 scope.empty? 확인으로 SQL을 더 쓰기 때문).
  class CaseFinder
    LIST_SIZE = 10
    COUNT_CAP = 500

    # dropped: 뺀 조건 이름([:decision, :job]), conditions: 결과를 낸 시도의 조건(더 자세히 찾기 링크용)
    Result = Data.define(:records, :more, :total_count, :over_cap, :dropped, :conditions)

    def initialize(conditions)
      @conditions = conditions
    end

    def call
      attempts.each do |conditions, dropped|
        scope, = DiseaseCase.main_search(search_params(conditions))
        records = scope.limit(LIST_SIZE + 1).to_a
        next if records.empty?

        count = scope.except(:order).limit(COUNT_CAP).count
        over_cap = count >= COUNT_CAP
        return Result.new(records: records.first(LIST_SIZE), more: records.size > LIST_SIZE,
          total_count: over_cap ? nil : count, over_cap: over_cap, dropped: dropped, conditions: conditions)
      end

      Result.new(records: [], more: false, total_count: 0, over_cap: false, dropped: [], conditions: @conditions)
    end

    private

    def job?(conditions)
      conditions.job_name_any.present? || conditions.job_name.present?
    end

    def attempts
      list = [ [ @conditions, [] ] ]
      current = @conditions
      dropped = []
      if current.decision.present?
        current = current.with(decision: nil)
        dropped += [ :decision ]
        list << [ current, dropped.dup ]
      end
      if job?(current)
        current = current.with(job_name_any: nil, job_name: nil)
        dropped += [ :job ]
        list << [ current, dropped.dup ]
      end
      list
    end

    def search_params(conditions)
      {
        burden_body_part: conditions.body_tokens.presence,
        job_name_any: conditions.job_name_any.presence,
        job_name: conditions.job_name.presence,
        result: conditions.decision.presence,
        fts_as_filter: true
      }.compact
    end
  end
end
