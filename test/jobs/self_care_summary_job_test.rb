# frozen_string_literal: true

require "test_helper"

class SelfCareSummaryJobTest < ActiveJob::TestCase
  setup do
    DiseaseCase.create!(case_no: "JOB-A", disease_name: "손목터널증후군", job_name: "택배원", burden_body_part: "손목",
      result: "approved", year: 2024, main_reasoning: "반복 작업", work_relevance_eval: "높음")
    @key = SelfCareForm::SummaryGenerator::Key.new(body_concept: "손목", job: "택배기사", decision: "")
    @row, = SelfCareSummary.claim(@key, SelfCareForm::SummaryGenerator.facts_for(@key).digest)
    with_exaone
  end

  def output(case_no)
    { recognized_reasons: [ { text: "반복 작업이 원인으로 판단된 사례가 있습니다.", case_nos: [ case_no ] } ], rejected_reasons: [],
      check_items: [], glossary: [] }
  end

  test "it runs on the dedicated exaone queue" do
    assert_equal "exaone", SelfCareSummaryJob.new.queue_name
    assert_enqueued_with(job: SelfCareSummaryJob, args: [ @row.id ], queue: "exaone") { SelfCareSummaryJob.perform_later(@row.id) }
  end

  test "success saves the summary" do
    SelfCareForm::SummaryGenerator.transport = ->(*) { exaone_response(output("JOB-A")) }
    SelfCareForm::SummaryGenerator.last_request_at = nil

    perform_enqueued_jobs { SelfCareSummaryJob.perform_later(@row.id) }

    assert @row.reload.ready?
    assert_equal "JOB-A", @row.summary_json["recognized_reasons"].first["case_nos"].first
  end

  test "failure marks the row failed and does not raise" do
    SelfCareForm::SummaryGenerator.transport = ->(*) { exaone_response(output("NOT-IN-INPUT")) }

    assert_nothing_raised { perform_enqueued_jobs { SelfCareSummaryJob.perform_later(@row.id) } }

    assert @row.reload.failed?
    assert_match(/입력에 없는 사건번호/, @row.error_message)
  end

  test "a row that is no longer pending is left alone" do
    @row.update!(status: "ready", summary_json: { "x" => 1 })
    SelfCareForm::SummaryGenerator.transport = ->(*) { flunk "호출하면 안 됨" }

    perform_enqueued_jobs { SelfCareSummaryJob.perform_later(@row.id) }

    assert_equal({ "x" => 1 }, @row.reload.summary_json)
  end

  test "a deleted row is discarded" do
    id = @row.id
    @row.destroy!

    assert_nothing_raised { perform_enqueued_jobs { SelfCareSummaryJob.perform_later(id) } }
  end
end
