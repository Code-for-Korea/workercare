# frozen_string_literal: true

module Chatbot
  # 검색어 토큰에 부분 일치하는 직종 이름을 후보로 모은다.
  #
  # 직종 이름은 판정서마다 표기가 달라 25,000여 가지다. 띄어쓰기만 다른 이름은 하나로 묶고
  # (대표 표기는 사전순 첫 값), 사례가 많은 순으로 보여 준다. 후보는 FETCH_LIMIT개까지만 가져와
  # 쪽 나누기는 호출한 쪽에서 한다.
  class JobCandidates
    Candidate = Struct.new(:name, :count, keyword_init: true)

    FETCH_LIMIT = 200
    NORMALIZED = "REPLACE(job_name, ' ', '')"

    def initialize(tokens, relation: DiseaseCase)
      @tokens = tokens
      @relation = relation
    end

    def call
      return [] if @tokens.empty?

      condition = Array.new(@tokens.size, "#{NORMALIZED} LIKE ?").join(" OR ")
      binds = @tokens.map { |token| "%#{@relation.sanitize_sql_like(token.delete(' '))}%" }

      @relation.where.not(job_name: [ nil, "" ]).where(condition, *binds)
        .group(Arel.sql(NORMALIZED))
        .order(Arel.sql("COUNT(*) DESC"), Arel.sql("MIN(job_name)"))
        .limit(FETCH_LIMIT)
        .pluck(Arel.sql("MIN(job_name)"), Arel.sql("COUNT(*)"))
        .map { |name, count| Candidate.new(name: name, count: count) }
    end
  end
end
