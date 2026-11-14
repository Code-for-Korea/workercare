# frozen_string_literal: true

# 단계별 사례 찾기의 쉬운 요약 한 건을 EXAONE으로 만든다. 전용 큐 `exaone`(config/queue.yml, 스레드 1개)에서만 돌려
# EXAONE의 초당 1회 한도를 지킨다. 실패는 SummaryGenerator가 행을 failed로 기록하므로 여기서 다시 던지지 않는다.
class SelfCareSummaryJob < ApplicationJob
  queue_as :exaone

  discard_on ActiveRecord::RecordNotFound

  def perform(summary_id)
    summary = SelfCareSummary.find(summary_id)
    return unless summary.pending?

    SelfCareForm::SummaryGenerator.new.generate(summary)
  end
end
