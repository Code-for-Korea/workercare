# frozen_string_literal: true

# 단계별 사례 찾기 결과의 "쉬운 요약" 한 건. 조건(body_concept, job, decision)과 데이터 지문(data_digest)마다 한 행이다.
# 조건 키에는 사전 개념 이름과 판정 결과 값만 들어간다(방문자 직접 입력 원문 금지). 설계: docs/self-care-form.md "쉬운 요약"
class SelfCareSummary < ApplicationRecord
  # 이 시간 넘게 pending이면 작업이 사라진 것으로 보고 다시 맡긴다.
  STALE_AFTER = 10.minutes

  enum :status, { pending: "pending", ready: "ready", failed: "failed" }, validate: true

  validates :data_digest, presence: true

  scope :stale_pending, -> { pending.where(updated_at: ...STALE_AFTER.ago) }

  # 조건과 지문으로 행을 찾고, 없으면 pending으로 만든다. 유일 인덱스가 동시 요청의 중복 생성을 막는다.
  # @return [Array(SelfCareSummary, Boolean)] [행, 이번 호출이 만들었는가]
  def self.claim(key, digest)
    attrs = { body_concept: key.body_concept, job: key.job, decision: key.decision, data_digest: digest }
    existing = find_by(attrs)
    return [ existing, false ] if existing

    [ create!(attrs.merge(status: "pending")), true ]
  rescue ActiveRecord::RecordNotUnique
    [ find_by!(attrs), false ]
  end

  def stale?
    pending? && updated_at < STALE_AFTER.ago
  end

  def key
    SelfCareForm::SummaryGenerator::Key.new(body_concept: body_concept, job: job, decision: decision)
  end
end
