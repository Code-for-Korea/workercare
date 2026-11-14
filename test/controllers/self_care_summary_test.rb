# frozen_string_literal: true

require "test_helper"

# 결과 화면의 쉬운 요약 프레임과 GET /self-care-form/summary의 상태별 응답.
class SelfCareSummaryTest < ActionDispatch::IntegrationTest
  Generator = SelfCareForm::SummaryGenerator

  setup do
    @case_a = DiseaseCase.create!(case_no: "SUMC-A", disease_name: "손목터널증후군", job_name: "택배원", burden_body_part: "손목",
      result: "approved", year: 2024, main_reasoning: "반복 작업", work_relevance_eval: "높음", job_description: "SECRET-JOB-DESC")
    @case_b = DiseaseCase.create!(case_no: "SUMC-B", disease_name: "회전근개파열", job_name: "택배원", burden_body_part: "어깨",
      result: "rejected", year: 2023, main_reasoning: "관련성 낮음")
    @key = Generator::Key.new(body_concept: "손목", job: "택배기사", decision: "")
  end

  def begin_session(body: "손목", job: "택배기사")
    post self_care_form_agree_path, params: { consent: "1" }
    post self_care_form_step_path("body_part"), params: { value: body } if body
    post self_care_form_step_path("job"), params: { value: job } if job
  end

  def summary_json
    {
      "meta" => { "total_count" => 1, "capped" => false, "shown_count" => 1, "distribution" => { "인정" => 1 } },
      "recognized_reasons" => [ { "text" => "반복 작업이 원인으로 판단된 사례가 있습니다.", "case_nos" => [ "SUMC-A" ] } ],
      "rejected_reasons" => [], "check_items" => [], "glossary" => [ { "term" => "수근관", "meaning" => "손목의 좁은 통로입니다." } ]
    }
  end

  def digest
    Generator.facts_for(@key).digest
  end

  def frame_request
    get self_care_form_summary_path, headers: { "Turbo-Frame" => "case_summary" }
  end

  test "the result page has a lazy turbo-frame above the case list when the feature is on" do
    with_exaone
    begin_session
    get self_care_form_result_path

    assert_response :success
    assert_select "turbo-frame#case_summary[src='#{self_care_form_summary_path}'][loading=lazy]", count: 1
    assert_select "turbo-frame#case_summary noscript", text: /JavaScript/
    html = response.body
    assert_operator html.index("case_summary"), :<, html.index("case-list")
  end

  test "the result page has no frame when the flag is off or the key is missing" do
    begin_session
    get self_care_form_result_path
    assert_select "turbo-frame#case_summary", count: 0

    ENV["EXAONE_SUMMARY_ENABLED"] = "1" # 키 없음
    get self_care_form_result_path
    assert_select "turbo-frame#case_summary", count: 0

    ENV.delete("EXAONE_SUMMARY_ENABLED")
    ENV["EXAONE_API_KEY"] = "test-key-not-real" # 플래그 꺼짐
    get self_care_form_result_path
    assert_select "turbo-frame#case_summary", count: 0
  end

  test "missing: creates a pending row, enqueues once, even for two requests, and shows the making-of text" do
    with_exaone
    begin_session

    assert_difference "SelfCareSummary.count", 1 do
      assert_enqueued_jobs 1, only: SelfCareSummaryJob do
        frame_request
        frame_request
      end
    end

    assert_response :success
    assert_select "turbo-frame#case_summary [data-controller=summary-poll][data-summary-poll-interval-value='2500'][data-summary-poll-timeout-value='60000']"
    assert_select "[data-summary-poll-target=waiting]", text: /만드는 중/
    assert_select "[data-summary-poll-target=timeout][hidden]"
    row = SelfCareSummary.last
    assert row.pending?
    assert_equal [ "손목", "택배기사", "" ], [ row.body_concept, row.job, row.decision ]
    assert_equal digest, row.data_digest
  end

  test "pending: does not enqueue again" do
    with_exaone
    begin_session
    SelfCareSummary.claim(@key, digest)

    assert_no_enqueued_jobs { frame_request }

    assert_select "[data-controller=summary-poll]"
  end

  test "polls look the pending row up by the id kept in the session without re-running CaseFinder" do
    with_exaone
    begin_session
    frame_request # 처음 요청: 전체 조회, 행 id를 세션에 둔다
    queries = 0
    counter = ->(*, payload) { queries += 1 if payload[:sql].include?("disease_cases") }

    ActiveSupport::Notifications.subscribed(counter, "sql.active_record") do
      assert_no_enqueued_jobs { frame_request }
    end

    assert_equal 0, queries, "폴링이 판정서 테이블을 다시 조회함"
    assert_select "[data-controller=summary-poll]"
  end

  test "changed answers or a reset stop using the remembered row" do
    with_exaone
    begin_session
    frame_request
    first = SelfCareSummary.last

    post self_care_form_step_path("job"), params: { value: "조리원" } # 답이 바뀜(손목·조리원은 결과가 없어 직업 조건이 빠진다)
    frame_request
    assert_select "turbo-frame#case_summary", count: 1
    assert_equal [ "손목", "" ], SelfCareSummary.where.not(id: first.id).pick(:body_concept, :job)

    post self_care_form_reset_path
    assert_nil session[:self_care_summary]
  end

  test "a pending row that has been stuck for a long time is handed to the queue again" do
    with_exaone
    begin_session
    row, = SelfCareSummary.claim(@key, digest)
    row.update_columns(updated_at: 11.minutes.ago)

    assert_enqueued_jobs 1, only: SelfCareSummaryJob do
      frame_request
    end
    assert row.reload.updated_at > 1.minute.ago
  end

  test "ready: renders the summary with notice, evidence links to the detail page and no polling" do
    with_exaone
    begin_session
    row, = SelfCareSummary.claim(@key, digest)
    row.update!(status: "ready", summary_json: summary_json, model: Generator::MODEL, prompt_version: "v1", generated_at: Time.current)

    assert_no_enqueued_jobs { frame_request }

    assert_response :success
    assert_select "turbo-frame#case_summary section.case-summary" do
      assert_select "h2", text: "판정서 쉬운 요약(AI 작성, 참고용)"
      assert_select ".notice", text: /원문을 꼭 확인하세요/
      assert_select "h3", text: /인정된 사례에서 자주 나온 이유/
      assert_select "li", text: /반복 작업이 원인으로 판단된 사례가 있습니다/
      assert_select "li a[href='#{disease_case_path('SUMC-A')}'][data-turbo-frame='_top']", text: "SUMC-A"
      assert_select "dt", text: "수근관"
      assert_select "[data-controller=summary-poll]", count: 0
    end
    assert_no_match(/SECRET/, response.body)
  end

  test "ready text is escaped" do
    with_exaone
    begin_session
    row, = SelfCareSummary.claim(@key, digest)
    row.update!(status: "ready", summary_json: summary_json.merge("check_items" => [ { "text" => "<script>alert(1)</script>", "case_nos" => [ "SUMC-A" ] } ]))

    frame_request

    assert_select "script", count: 0 # 레이아웃의 스크립트가 아니라 프레임 안에서만 본다
    assert_no_match(/<script>alert/, response.body)
  end

  test "failed: shows a short note, does not enqueue" do
    with_exaone
    begin_session
    row, = SelfCareSummary.claim(@key, digest)
    row.update!(status: "failed", error_message: "x")

    assert_no_enqueued_jobs { frame_request }

    assert_select "turbo-frame#case_summary p", text: /요약을 만들지 못했습니다/
    assert_select "[data-controller=summary-poll]", count: 0
  end

  test "flag off or no key: an empty frame and no row" do
    begin_session

    assert_no_difference "SelfCareSummary.count" do
      assert_no_enqueued_jobs { frame_request }
    end

    assert_response :success
    assert_select "turbo-frame#case_summary", count: 1
    assert_select "turbo-frame#case_summary *", count: 0
  end

  test "an unmatched free-text job says there is no summary for this condition" do
    with_exaone
    post self_care_form_agree_path, params: { consent: "1" }
    post self_care_form_step_path("body_part"), params: { value: "손목" }
    post self_care_form_step_path("job"), params: { free_text: "배원" } # LIKE로는 찾지만 사전에는 없다

    assert_no_difference "SelfCareSummary.count" do
      frame_request
    end

    assert_select "turbo-frame#case_summary p", text: "이 조건의 요약은 없습니다."
  end

  test "no consent or no results renders an empty frame" do
    with_exaone
    get self_care_form_summary_path, headers: { "Turbo-Frame" => "case_summary" }
    assert_select "turbo-frame#case_summary *", count: 0

    begin_session(body: "무릎", job: nil) # 일치하는 사례가 없는 조건
    frame_request
    assert_select "turbo-frame#case_summary *", count: 0
  end

  test "free text never reaches the condition key or the request" do
    with_exaone
    post self_care_form_agree_path, params: { consent: "1" }
    post self_care_form_step_path("body_part"), params: { free_text: "왼쪽 손목 SECRET-TYPED" }
    post self_care_form_step_path("job"), params: { free_text: "택배원" }
    sent = []
    Generator.transport = ->(_uri, _headers, body) { sent << body; exaone_response("{}") }

    perform_enqueued_jobs { frame_request }

    row = SelfCareSummary.last
    assert_equal [ "손목", "택배기사", "" ], [ row.body_concept, row.job, row.decision ]
    assert_no_match(/SECRET-TYPED|왼쪽/, [ row.attributes.values, sent ].flatten.join(" "))
  end

  test "the response is not cacheable" do
    with_exaone
    begin_session
    frame_request

    assert_match(/no-store/, response.headers["Cache-Control"])
  end
end
