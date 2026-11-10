# frozen_string_literal: true

require "test_helper"

# 구글 폼으로 통계를 보내는 기능(기본 꺼짐). 네트워크 없이 transport를 바꿔 끼워 검증한다.
# "8개" 단언은 샘플 폼 기준의 샘플 고정 테스트다: test/fixtures/files/self_care_form_sample.yml을 주입하며
# 커밋된 config/self_care_form.yml이나 운영 폼과 무관하다.
class SelfCareFormGoogleTest < ActionDispatch::IntegrationTest
  Response = Struct.new(:code)

  setup do
    @sent = []
    SelfCareForm::Settings.current = SelfCareForm::Settings.load(file_fixture("self_care_form_sample.yml"))
    SelfCareForm::GoogleFormSubmitter.transport = lambda do |uri, params|
      @sent << [ uri, params ]
      Response.new("200")
    end
  end

  teardown do
    SelfCareForm::Settings.reset!
    SelfCareForm::GoogleFormSubmitter.transport = nil
  end

  def begin_session(stats: true)
    post self_care_form_agree_path, params: { consent: "1", stats_consent: (stats ? "1" : nil) }.compact
  end

  def answer(step, **params)
    post self_care_form_step_path(step), params: params
  end

  def answer_everything
    answer("situation", value: "ill")
    answer("body_part", value: "손목")
    answer("job", value: "택배기사")
    answer("decision", value: "all")
    answer("profile", respondent: "본인", application_experience: "아직 안 함", age_band: "30대", region: "서울")
  end

  # [결과 보기]. 서버(Puma)가 만들어 주는 콜백 배열을 흉내 낸다.
  # Rails 실행기도 같은 배열에 자기 완료 처리(proc)를 넣으므로, 우리 콜백(람다)만 골라서 돌려준다.
  def submit(callbacks = [])
    post self_care_form_submit_result_path, env: { "rack.response_finished" => callbacks }
    callbacks.select(&:lambda?)
  end

  def fire_callbacks(callbacks, error: nil)
    callbacks.reverse_each { |callback| callback.call({}, 302, {}, error) }
  end

  # ---- 켜졌을 때의 화면 ----

  test "when on, the start page asks for the optional statistics consent with the plain-language notice" do
    get self_care_form_start_path

    assert_select "input#stats_consent[type=checkbox]"
    assert_select "label[for=stats_consent]", text: /\(선택\)/
    assert_select "#stats-consent-detail", text: /서버의 IP를 봅니다/
    assert_select "#stats-consent-detail", text: /재식별 위험/
    assert_select "#stats-consent-detail", text: /답이 달라질 때마다 전송되며, 같은 답은 다시 보내지 않습니다/
    assert_select "#stats-consent-detail", text: /직접 입력한 말은 보내지 않습니다/
    assert_select "#stats-consent-detail", text: /직접 입력.*모르겠어요.*고정 문구만 보냅니다/
    assert_no_match(/개인정보가 가지 않/, response.body)
    assert_every_input_labelled
  end

  test "when off, there is no statistics checkbox and no notice about it" do
    SelfCareForm::Settings.current = SelfCareForm::Settings.new(enabled: false, url: "", entries: {})
    get self_care_form_start_path

    assert_select "input#stats_consent", count: 0
    assert_select "#stats-consent-detail", count: 0
    assert_no_match(/답이 달라질 때마다 전송/, response.body)
  end

  test "when on, the review page shows a POST button instead of a plain link" do
    begin_session
    get self_care_form_review_path

    assert_select "form[action='#{self_care_form_submit_result_path}'][method=post] button", text: "결과 보기"
    assert_select "a[href='#{self_care_form_result_path}']", count: 0

    SelfCareForm::Settings.current = SelfCareForm::Settings.new(enabled: false, url: "", entries: {})
    get self_care_form_review_path
    assert_select "a[role=button][href='#{self_care_form_result_path}']", text: "결과 보기"
  end

  def assert_every_input_labelled
    css_select("input, select, textarea").each do |input|
      next if %w[hidden submit button].include?(input["type"])

      labelled = input["id"].present? && css_select("label[for='#{input['id']}']").any?
      assert labelled || input.ancestors("label").any?, "label이 없는 입력: #{input}"
    end
  end

  # ---- 보내기 ----

  test "consenting users get one callback registered after the response and nothing is sent during the request" do
    begin_session
    answer_everything
    callbacks = submit

    assert_redirected_to self_care_form_result_path
    assert_equal 1, callbacks.size
    assert_empty @sent, "응답을 만드는 동안에는 구글을 부르지 않는다"

    fire_callbacks(callbacks)
    assert_equal 1, @sent.size
    uri, params = @sent.first
    assert_equal SelfCareForm::Settings.current.url, uri.to_s
    assert_equal 8, params.size, "샘플 설정: 검색 3개 + 상황 1개 + 프로필 4개"
    assert_equal "손목", params["entry.447515540"]
    assert_equal "택배기사", params["entry.574759984"]
    assert_equal "모두 보기", params["entry.44280323"]
  end

  test "skipped answers send fewer parameters; skipping the whole profile removes four" do
    begin_session
    answer("situation", value: "no_time")
    answer("body_part", value: "none")
    answer("job", value: "none")
    answer("decision", value: "skip")
    answer("profile", skip_to_review: "1")
    fire_callbacks(submit)

    assert_equal 2, @sent.first.last.size, "상황 + 직업 \"모르겠어요\" 라벨"
    assert_equal SelfCareForm::Flow.situation_label("no_time"), @sent.first.last["entry.1830980629"]
  end

  test "users who did not consent send nothing and are never get a digest" do
    begin_session(stats: false)
    answer_everything
    callbacks = submit
    follow_redirect!

    assert_empty callbacks
    assert_empty @sent
    assert_nil session[:self_care_form_last_digest]
    assert_select ".notice", text: /통계 응답으로 보냈습니다/, count: 0
  end

  test "pressing show-results again with the same answers sends only once and the notice says it was sent this time" do
    begin_session
    answer_everything
    assert_equal 1, submit.size
    follow_redirect!
    assert_select ".notice[role=status]", text: /이번 선택을 통계 응답으로 보냈습니다/

    assert_empty submit, "같은 답으로 두 번째 [결과 보기]"
    follow_redirect!
    assert_select ".notice", text: /통계 응답으로 보냈습니다/, count: 0
  end

  test "changing an answer and pressing show-results again sends a second time" do
    begin_session
    answer_everything
    fire_callbacks(submit)
    answer("body_part", value: "무릎")
    fire_callbacks(submit)

    assert_equal 2, @sent.size
    assert_equal "무릎", @sent.last.last["entry.447515540"]
  end

  test "reloading the result page never sends" do
    begin_session
    answer_everything
    get self_care_form_result_path
    get self_care_form_result_path

    assert_empty @sent
    assert_nil session[:self_care_form_last_digest]
  end

  test "starting over with identical answers does not resend, with different answers it does" do
    begin_session
    answer_everything
    fire_callbacks(submit)

    post self_care_form_reset_path
    begin_session
    answer_everything
    assert_empty submit, "같은 답은 다시 보내지 않는다"

    post self_care_form_reset_path
    begin_session
    answer_everything
    answer("job", value: "용접공")
    fire_callbacks(submit)
    assert_equal 2, @sent.size
  end

  test "a different result_count with the same answers does not resend, but relaxed and result_count are still sent" do
    SelfCareForm::Settings.current = SelfCareForm::Settings.new(enabled: true, url: SelfCareForm::Settings.current.url,
      entries: SelfCareForm::Settings.current.entries.merge("relaxed" => "111", "result_count" => "222"))
    begin_session
    answer_everything
    fire_callbacks(submit)
    assert_match(/\A\d+\z/, @sent.first.last["entry.222"])

    fake = Struct.new(:call).new(SelfCareForm::CaseFinder::Result.new(records: [], more: false, total_count: 99_999,
      over_cap: false, dropped: [], conditions: nil))
    SelfCareForm::CaseFinder.singleton_class.alias_method :__orig_new, :new
    SelfCareForm::CaseFinder.define_singleton_method(:new) { |*| fake }
    begin
      assert_empty submit, "데이터가 달라져도 답이 같으면 보내지 않는다"
    ensure
      SelfCareForm::CaseFinder.singleton_class.alias_method :new, :__orig_new
      SelfCareForm::CaseFinder.singleton_class.remove_method :__orig_new
    end
    assert_equal 1, @sent.size
  end

  test "the session keeps only the hex digest, never the answers" do
    begin_session
    answer_everything
    submit
    assert_match(/\A\h{64}\z/, session[:self_care_form_last_digest])
  end

  test "the digest is set in the request itself so a failing google request is not retried for the same answers" do
    SelfCareForm::GoogleFormSubmitter.transport = ->(_uri, _params) { raise Net::OpenTimeout }
    begin_session
    answer_everything
    callbacks = submit
    assert_includes response.headers["Set-Cookie"].to_s, "_session", "해시는 응답의 세션 쿠키에 실린다"

    assert_nothing_raised { fire_callbacks(callbacks) }
    assert_empty submit, "실패해도 같은 답으로는 재시도하지 않는다"
  end

  test "a callback never lets an exception escape" do
    boom = Class.new(StandardError)
    SelfCareForm::GoogleFormSubmitter.transport = ->(_uri, _params) { raise boom, "구글 비밀값" }
    begin_session
    answer_everything
    callbacks = submit

    assert_nothing_raised { fire_callbacks(callbacks) }
  end

  test "nothing is sent when the server reports an error for the response" do
    begin_session
    answer_everything
    callbacks = submit
    fire_callbacks(callbacks, error: RuntimeError.new("응답 실패"))

    assert_empty @sent
  end

  test "without the rack.response_finished array nothing is sent synchronously and the digest stays unset for a later try" do
    begin_session
    answer_everything
    post self_care_form_submit_result_path
    assert_redirected_to self_care_form_result_path
    assert_empty @sent, "요청 처리 중 동기로 구글을 부르지 않는다"
    assert_nil session[:self_care_form_last_digest]

    callbacks = submit
    assert_equal 1, callbacks.size, "해시가 켜지지 않았으므로 다시 시도할 수 있다"
  end

  test "typed text and the statistics labels never go beyond the configured entries" do
    begin_session
    answer("body_part", free_text: "왼쪽 손목 비밀문장")
    answer("job", free_text: "내 이름은 홍길동")
    answer("profile", respondent: "유가족", application_experience: "불승인을 받음", age_band: "10대", region: "충남")
    fire_callbacks(submit)

    values = @sent.first.last.values
    assert_includes values, "손목", "원문이 아니라 사전 개념 이름"
    assert_no_match(/비밀문장|홍길동/, values.join)
    assert_equal 6, @sent.first.last.size, "손목 + 직업 고정 문구 + 프로필 4개(판정·상황은 건너뜀)"
  end

  test "unmatched body-part free text with a distinctive string is never in any submitted parameter" do
    begin_session
    answer("body_part", free_text: "zzqx유니크문자열")
    answer("job", free_text: "yyqw유니크직업")
    fire_callbacks(submit)

    assert_equal 1, @sent.size
    all = @sent.flat_map { |uri, params| [ uri.to_s, *params.keys, *params.values ] }.join(" ")
    assert_no_match(/zzqx|yyqw|유니크/, all)
  end

  test "an unmatched typed job sends the fixed placeholder and nothing from the typed text" do
    begin_session
    answer("job", free_text: "비밀직업 홍길동")
    fire_callbacks(submit)

    params = @sent.first.last
    assert_equal "직접 입력", params["entry.574759984"]
    assert_no_match(/비밀|직업|홍길동/, params.values.join)
  end

  test "the I-don't-know job choice sends its label" do
    begin_session
    answer("job", value: "none")
    fire_callbacks(submit)

    assert_equal "모르겠어요", @sent.first.last["entry.574759984"]
  end

  test "choosing none for body_part stores no extra key" do
    begin_session
    answer("body_part", value: "none")

    assert_empty session[:self_care_form].keys - SelfCareForm::Answers::KEYS
    assert_nil session[:self_care_form]["body_part_unknown"]
  end

  test "a matched job is sent unchanged and a later typed answer replaces the unknown mark" do
    begin_session
    answer("job", value: "none")
    answer("job", value: "택배기사")
    fire_callbacks(submit)

    assert_equal "택배기사", @sent.first.last["entry.574759984"]
  end

  test "relaxed and result_count are computed and sent only when the form has those questions" do
    SelfCareForm::Settings.current = SelfCareForm::Settings.new(enabled: true, url: SelfCareForm::Settings.current.url,
      entries: SelfCareForm::Settings.current.entries.merge("relaxed" => "111", "result_count" => "222"))
    begin_session
    answer("body_part", value: "손목")
    fire_callbacks(submit)

    params = @sent.first.last
    assert_equal "아니오", params["entry.111"]
    assert_match(/\A\d+\z/, params["entry.222"])
  end

  # ---- 꺼져 있을 때 ----

  test "when off, submitting just shows the result: no callback, no flag" do
    SelfCareForm::Settings.current = SelfCareForm::Settings.new(enabled: false, url: "", entries: {})
    begin_session
    answer_everything
    callbacks = submit

    assert_redirected_to self_care_form_result_path
    assert_empty callbacks
    assert_empty @sent
    follow_redirect!
    assert_select ".notice", text: /통계 응답으로 보냈습니다/, count: 0
  end
end
