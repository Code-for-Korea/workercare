# frozen_string_literal: true

require "test_helper"

class SelfCareForm::GoogleFormSubmitterTest < ActiveSupport::TestCase
  Submitter = SelfCareForm::GoogleFormSubmitter
  Response = Struct.new(:code)

  setup do
    @settings = SelfCareForm::Settings.load(file_fixture("self_care_form_sample.yml"))
    @log = StringIO.new
    @logger = Logger.new(@log)
    @calls = []
    @transport = lambda do |uri, params|
      @calls << [ uri, params ]
      Response.new("200")
    end
  end

  def submitter(settings = @settings, transport = @transport)
    Submitter.new(settings: settings, transport: transport, logger: @logger)
  end

  def full_answers
    SelfCareForm::Answers.new("situation" => "ill", "body_part" => "손목", "job" => "택배기사", "decision" => "all",
      "respondent" => "본인", "application_experience" => "아직 안 함", "age_band" => "30대", "region" => "서울")
  end

  test "answering everything sends exactly the eight configured questions with the Flow labels" do
    params = submitter.form_params(Submitter.values_for(full_answers))

    assert_equal 8, params.size
    assert_equal "손목", params["entry.447515540"]
    assert_equal "택배기사", params["entry.574759984"]
    assert_equal "모두 보기", params["entry.44280323"]
    assert_equal "30대", params["entry.1913665441"]
    assert_equal "서울", params["entry.1602965800"]
    assert_equal "아직 안 함", params["entry.1496037600"]
    assert_equal "본인", params["entry.1305751224"]
    assert_equal SelfCareForm::Flow.situation_label("ill"), params["entry.1830980629"]
  end

  test "skipped answers shrink the payload one key at a time" do
    base = full_answers.to_h
    {
      "situation" => "entry.1830980629", "body_part" => "entry.447515540", "job" => "entry.574759984",
      "decision" => "entry.44280323", "respondent" => "entry.1305751224", "age_band" => "entry.1913665441"
    }.each do |key, entry|
      params = submitter.form_params(Submitter.values_for(SelfCareForm::Answers.new(base.except(key))))
      assert_equal 7, params.size, key
      refute params.key?(entry), key
    end

    no_profile = SelfCareForm::Answers.new(base.except(*SelfCareForm::Answers::PROFILE_KEYS))
    assert_equal 4, submitter.form_params(Submitter.values_for(no_profile)).size, "프로필 전체를 건너뛰면 4개 감소"
  end

  test "skipping the decision sends nothing for it while pressing show-all sends the label" do
    skipped = Submitter.values_for(SelfCareForm::Answers.new("situation" => "ill"))
    refute skipped.key?("decision")
    assert_equal "모두 보기", Submitter.values_for(SelfCareForm::Answers.new("decision" => "all"))["decision"]
    assert_equal "불인정", Submitter.values_for(SelfCareForm::Answers.new("decision" => "rejected"))["decision"]
  end

  test "typed text is never sent: only the dictionary concept or the job button" do
    typed = SelfCareForm::Answers.new("body_part_text" => "왼쪽 손목 비밀문장", "job_text" => "내 이름은 홍길동")
    values = Submitter.values_for(typed)

    assert_equal "손목", values["body_part"], "원문이 아니라 사전 개념 이름"
    assert_equal "직접 입력", values["job"], "직접 입력한 직업은 원문 대신 고정 문구"
    assert_no_match(/비밀문장|홍길동/, values.values.join)

    unmatched = Submitter.values_for(SelfCareForm::Answers.new("body_part_text" => "등산 중 다침"))
    refute unmatched.key?("body_part")
  end

  test "relaxed and result_count are sent only when a result is given and they are configured" do
    result = SelfCareForm::CaseFinder::Result.new(records: [], more: false, total_count: 7, over_cap: false,
      dropped: [ :decision, :job ], conditions: nil)
    values = Submitter.values_for(full_answers, result: result)

    assert_equal "예(판정 결과, 직업)", values["relaxed"]
    assert_equal "7", values["result_count"]
    assert_equal 8, submitter.form_params(values).size, "샘플 설정에는 relaxed·result_count가 없어 항상 0개"

    with_both = SelfCareForm::Settings.new(enabled: true, url: @settings.url,
      entries: @settings.entries.merge("relaxed" => "111", "result_count" => "222"))
    params = submitter(with_both).form_params(values)
    assert_equal 10, params.size
    assert_equal "7", params["entry.222"]

    capped = SelfCareForm::CaseFinder::Result.new(records: [], more: false, total_count: nil, over_cap: true, dropped: [], conditions: nil)
    assert_equal "500 이상", Submitter.values_for(full_answers, result: capped)["result_count"]
    assert_equal "아니오", Submitter.values_for(full_answers, result: capped)["relaxed"]
  end

  test "submit posts the params to the configured uri and reports the status without claiming success" do
    outcome = submitter.submit(Submitter.values_for(full_answers))

    assert outcome.sent
    assert_equal 200, outcome.status
    assert_equal 1, @calls.size
    uri, params = @calls.first
    assert_equal @settings.url, uri.to_s
    assert_equal 8, params.size
    assert_match(/status=200/, @log.string)
  end

  test "failures never raise, are logged by class only, and leave no values in the log" do
    boom = ->(_uri, _params) { raise Net::OpenTimeout, "구글 응답 없음 비밀값" }
    outcome = submitter(@settings, boom).submit(Submitter.values_for(full_answers))

    refute outcome.sent
    assert_equal "Net::OpenTimeout", outcome.error
    assert_match(/전송 실패 \(Net::OpenTimeout\)/, @log.string)
    assert_no_match(/비밀값|택배기사|손목/, @log.string)
  end

  test "a non-2xx status is logged and still not an exception" do
    outcome = submitter(@settings, ->(_u, _p) { Response.new("401") }).submit(Submitter.values_for(full_answers))

    assert outcome.sent
    assert_equal 401, outcome.status
    assert_match(/2xx가 아닌 상태를 돌려줬습니다 \(status=401\)/, @log.string)
  end

  test "an invalid config or nothing to send does not call out" do
    bad = SelfCareForm::Settings.new(enabled: true, url: "http://bad", entries: { "body_part" => "1" })
    refute submitter(bad).submit("body_part" => "손목").sent
    assert_empty @calls

    refute submitter.submit({}).sent
    assert_empty @calls
  end

  test "the default transport uses https with one second timeouts and does not follow redirects" do
    captured = {}
    fake_http = Object.new
    fake_http.define_singleton_method(:request) { |request| captured[:request] = request; Response.new("302") }
    fake_net = Object.new
    fake_net.define_singleton_method(:start) do |host, port, **options, &block|
      captured.merge!(host: host, port: port, options: options)
      block.call(fake_http)
    end

    outcome = Submitter.new(settings: @settings, logger: @logger, http: fake_net).submit("body_part" => "손목")
    assert_equal 302, outcome.status, "3xx는 따라가지 않고 비 2xx로 취급한다"

    assert_equal "docs.google.com", captured[:host]
    assert_equal 443, captured[:port]
    assert_equal({ use_ssl: true, open_timeout: 1, read_timeout: 1 }, captured[:options])
    assert_equal "entry.447515540=%EC%86%90%EB%AA%A9", captured[:request].body
    assert_match(/status=302/, @log.string)
  end

  test "test values start with the marker and cover only the given keys" do
    values = Submitter.test_values(%w[body_part job])
    assert_equal %w[body_part job], values.keys
    assert values.values.all? { |v| v.start_with?("[테스트]") }
  end
end
