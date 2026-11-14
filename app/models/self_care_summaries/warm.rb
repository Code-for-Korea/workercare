# frozen_string_literal: true

module SelfCareSummaries
  # rake self_care_summaries:warm이 미리 만들 조건 조합을 고른다: 신체부위 개념(없음 포함) × 사전 직종(없음 포함),
  # 판정 결과는 "모두 보기"(빈 값). 둘 다 없는 조합은 뺀다. 기본은 신체부위가 있는 조합만이다(ANY_BODY=1이면 직종만 있는 조합도). 판정서 건수가 많은 순서로 고른다.
  module Warm
    Combo = Data.define(:key, :facts)
    ESTIMATED_SECONDS_EACH = 40 # 추론 토큰 때문에 건당 수십 초. 파일럿에서 실측해 고친다.

    class << self
      # @param require_body [Boolean] true(기본)면 신체부위가 있는 조합만. 직종만 있는 조합은 여러 질병이 섞여 덜 일관되므로 뒤로 미룬다.
      # @return [Array<Combo>] 건수(500 상한) 내림차순, 같으면 키 이름순
      def combinations(limit, require_body: true)
        bodies = (require_body ? [] : [ "" ]) + SelfCareForm::Flow.body_part_names
        jobs = [ "" ] + Chatbot::EntityDictionary.concepts("job_name").keys
        keys = bodies.product(jobs).map { |body, job| SelfCareForm::SummaryGenerator::Key.new(body_concept: body, job: job, decision: "") }
        keys = keys.select(&:valid?)
        combos = keys.filter_map do |key|
          facts = SelfCareForm::SummaryGenerator.facts_for(key)
          Combo.new(key: key, facts: facts) if facts
        end
        combos.sort_by { |c| [ -c.facts.total_count, c.key.body_concept, c.key.job ] }.first(limit)
      end
    end
  end
end
