# frozen_string_literal: true

require "test_helper"
require "tmpdir"

class SolarExtraction::RunnerTest < ActiveSupport::TestCase
  # 가짜 클라이언트: 호출을 세고, 입력에서 case를 구분해 결과를 준다. 네트워크 없음.
  class FakeClient
    attr_reader :calls, :model

    def initialize(fail_for: [], model: "fake-model")
      @calls = Queue.new
      @fail_for = fail_for
      @model = model
    end

    def extract(messages:, schema_name:, schema:, estimated_tokens:, max_tokens: nil)
      @max_tokens_seen = max_tokens
      text = messages.last[:content]
      @calls << text
      raise SolarExtraction::RetriesExhausted.new(attempts: 3, last_error: "http:429") if @fail_for.any? { |marker| text.include?(marker) }

      quote = text[/고혈압/] ? "고혈압으로 치료" : ""
      content = {
        "comorbidities" => { "value" => quote.empty? ? [] : [ "고혈압" ], "evidence_quote" => quote, "mention" => quote.empty? ? "언급없음" : "있음" },
        "smoking" => { "value" => "미확인", "evidence_quote" => "", "mention" => "언급없음" },
        "alcohol" => { "value" => "미확인", "evidence_quote" => "", "mention" => "언급없음" }
      }
      SolarExtraction::Client::Response.new(content: content, usage: { prompt_tokens: 100, completion_tokens: 10, reasoning_tokens: 0, total_tokens: 110 },
                                            model: "fake-model-1", finish_reason: "stop", attempts: 1)
    end

    attr_reader :max_tokens_seen

    def call_count = @calls.size
  end

  setup do
    @dir = Dir.mktmpdir("solar_runner")
    @task = SolarExtraction::Tasks.fetch("comorbidity")
    @io = StringIO.new
    5.times do |i|
      DiseaseCase.create!(case_no: "T-#{i}", disease_category: "musculoskeletal", result: "approved",
                          medical_records: i.zero? ? "고혈압으로 치료 중 CASE#{i}" : "소견 CASE#{i}", recognized_facts: "사실 CASE#{i}")
    end
    DiseaseCase.create!(case_no: "T-empty", medical_records: nil, recognized_facts: "", committee_decision: " ")
  end

  teardown { FileUtils.remove_entry(@dir) }

  def runner(**options)
    SolarExtraction::Runner.new(task: @task, out_dir: @dir, io: @io, trap_signals: false, progress_every: 2, **options)
  end

  def results = File.readlines(File.join(@dir, "results.jsonl")).map { |l| JSON.parse(l) }
  def failures = File.exist?(File.join(@dir, "failures.jsonl")) ? File.readlines(File.join(@dir, "failures.jsonl")).map { |l| JSON.parse(l) } : []

  test "dry-run은 클라이언트도 파일도 만들지 않고 추정만 출력한다" do
    client = FakeClient.new
    summary = runner(client: client, limit: 3).run

    assert_equal :dry_run, summary[:mode]
    assert_equal 0, client.call_count
    assert_equal 3, summary[:estimate].cases
    assert_not File.exist?(File.join(@dir, "results.jsonl"))
    assert_match(/DRY-RUN/, @io.string)
    assert_match(/추정 비용: \$/, @io.string)
    assert_no_match(/CASE\d/, @io.string)
  end

  test "실행기는 과제의 max_tokens를 클라이언트에 넘긴다" do
    client = FakeClient.new
    runner(client: client, apply: true, limit: 1).run
    assert_equal @task.max_tokens, client.max_tokens_seen
  end

  test "dry-run은 API 키 없이도 돌아간다" do
    original = ENV.delete("UPSTAGE_API_KEY")
    assert_nothing_raised { runner.run }
  ensure
    ENV["UPSTAGE_API_KEY"] = original if original
  end

  test "APPLY는 JSONL에 결과를 쓰고 빈 입력은 호출 없이 invalid로 기록한다" do
    client = FakeClient.new
    runner(client: client, apply: true).run

    rows = results.index_by { |r| r["case_no"] }
    assert_equal 6, rows.size
    assert_equal 5, client.call_count
    ok = rows["T-0"]
    assert_equal "ok", ok["status"]
    assert_equal "comorbidity", ok["task"]
    assert_equal "fake-model-1", ok["model"]
    assert_equal @task.prompt_version, ok["prompt_version"]
    assert_equal @task.schema_version, ok["schema_version"]
    assert_equal 110, ok["usage"]["total_tokens"]
    assert_equal [ "고혈압" ], ok["output"]["comorbidities"]["value"]
    assert ok["extracted_at"]
    assert_equal "invalid", rows["T-empty"]["status"]
    assert_match(/empty_input/, rows["T-empty"]["validation_errors"].first)
  end

  test "검증에 실패한 출력은 invalid로 기록한다" do
    DiseaseCase.where.not(case_no: "T-1").delete_all
    bad = FakeClient.new
    bad.define_singleton_method(:extract) do |**|
      SolarExtraction::Client::Response.new(content: { "x" => 1 }, usage: { prompt_tokens: 1, completion_tokens: 1, reasoning_tokens: 0, total_tokens: 2 },
                                            model: "m", finish_reason: "stop", attempts: 1)
    end
    runner(client: bad, apply: true).run

    row = results.first
    assert_equal "invalid", row["status"]
    assert_not_empty row["validation_errors"]
  end

  test "이어 받기: 끝낸 건은 다시 호출하지 않는다" do
    first = FakeClient.new
    runner(client: first, apply: true, limit: 3).run
    assert_equal 3, results.size

    second = FakeClient.new
    runner(client: second, apply: true).run
    assert_equal 6, results.map { |r| r["case_no"] }.uniq.size
    assert_equal 6, results.size
    assert_equal 2, second.call_count # 남은 5건 중 빈 입력 1건은 호출 없음, 앞 3건 중 호출이 있던 것 제외
  end

  test "실패는 failures.jsonl에 원문 없이 기록되고 재실행 때 다시 시도한다" do
    client = FakeClient.new(fail_for: [ "CASE2" ])
    runner(client: client, apply: true).run

    assert_equal [ "T-2" ], failures.map { |f| f["case_no"] }
    failure = failures.first
    assert_equal "SolarExtraction::RetriesExhausted", failure["error_class"]
    assert_no_match(/CASE2|소견|사실/, failure.to_json)
    assert_equal 5, results.size

    retry_client = FakeClient.new
    runner(client: retry_client, apply: true).run
    assert_equal 1, retry_client.call_count
    assert_includes results.map { |r| r["case_no"] }, "T-2"
  end

  test "SKIP_FAILED면 실패 건을 건너뛴다" do
    runner(client: FakeClient.new(fail_for: [ "CASE2" ]), apply: true).run
    again = FakeClient.new
    runner(client: again, apply: true, skip_failed: true).run

    assert_equal 0, again.call_count
    assert_not_includes results.map { |r| r["case_no"] }, "T-2"
  end

  test "동시성 2에서도 각 건은 한 번만 처리된다" do
    client = FakeClient.new
    runner(client: client, apply: true, concurrency: 2).run

    assert_equal 6, results.map { |r| r["case_no"] }.tally.values.sum
    assert_equal results.size, results.map { |r| r["case_no"] }.uniq.size
    assert_equal 5, client.call_count
    assert(results.all? { |r| JSON.generate(r).present? })
  end

  test "SCOPE: disease_category와 empty_rows" do
    DiseaseCase.create!(case_no: "T-cv", disease_category: "cardiovascular", medical_records: "소견 CASE9")
    client = FakeClient.new
    runner(client: client, apply: true, scope: "disease_category=cardiovascular").run
    assert_equal [ "T-cv" ], results.map { |r| r["case_no"] }

    DiseaseCase.where(case_no: "T-3").update_all(job_name: "용접공")
    summary = runner(scope: "empty_rows").run
    assert_equal 6, summary[:skipped][:scope_total] # T-3은 job_name이 있어 제외(7건 중 6)
  end

  test "SCOPE: case_nos 파일" do
    path = File.join(@dir, "list.txt")
    File.write(path, "T-1\nT-4\n\n")
    out = Dir.mktmpdir("solar_out")
    SolarExtraction::Runner.new(task: @task, out_dir: out, io: @io, trap_signals: false, apply: true, client: FakeClient.new, scope: "case_nos=#{path}").run
    assert_equal %w[T-1 T-4], File.readlines(File.join(out, "results.jsonl")).map { |l| JSON.parse(l)["case_no"] }.sort
  ensure
    FileUtils.remove_entry(out) if out
  end

  test "APPLY인데 키가 없고 클라이언트도 없으면 거부한다" do
    original = ENV.delete("UPSTAGE_API_KEY")
    assert_raises(SolarExtraction::MissingApiKey) { runner(apply: true).run }
  ensure
    ENV["UPSTAGE_API_KEY"] = original if original
  end

  test "401 같은 되돌릴 수 없는 오류는 실행을 멈춘다" do
    client = FakeClient.new
    client.define_singleton_method(:extract) { |**| raise SolarExtraction::ClientError.new(status: 401, code: "invalid_api_key") }
    summary = runner(client: client, apply: true).run

    assert_match(/중단/, summary[:aborted])
    assert_operator failures.size, :<, 6
  end

  test "저장이 실패해 워커가 죽어도 실행은 끝나고 오류를 올리며 나머지는 쓰지 않는다" do
    runner = runner(client: FakeClient.new, apply: true, concurrency: 2)
    store = runner.instance_variable_get(:@store)
    store.define_singleton_method(:write_result) { |_| raise IOError, "disk full" }

    error = Timeout.timeout(10) { assert_raises(IOError) { runner.run } }
    assert_equal "disk full", error.message
    assert_not File.exist?(File.join(@dir, "results.jsonl"))
  end

  test "다른 실행이 OUT_DIR 락을 잡고 있으면 APPLY는 시작하지 않는다" do
    File.open(File.join(@dir, ".lock"), File::RDWR | File::CREAT) do |held|
      assert held.flock(File::LOCK_EX | File::LOCK_NB)
      client = FakeClient.new
      error = assert_raises(SolarExtraction::Runner::Locked) { runner(client: client, apply: true).run }

      assert_match(/다른 실행이 진행 중/, error.message)
      assert_equal 0, client.call_count
      assert_not File.exist?(File.join(@dir, "results.jsonl"))
      assert_nothing_raised { runner(client: client).run } # dry-run은 락을 보지 않는다
    end
    runner(client: FakeClient.new, apply: true).run # 풀리면 돌 수 있다
    assert_equal 6, results.size
  end

  test "TERM을 받으면 진행 중인 건만 마치고 나머지는 쓰지 않으며 이어 받을 수 있다" do
    client = FakeClient.new
    first_call = true
    original = client.method(:extract)
    client.define_singleton_method(:extract) do |**args|
      if first_call
        first_call = false
        Process.kill("TERM", Process.pid)
        sleep 0.3 # 핸들러가 중단 플래그를 세울 시간
      end
      original.call(**args)
    end
    summary = SolarExtraction::Runner.new(task: @task, out_dir: @dir, io: @io, progress_every: 2, apply: true, client: client).run

    assert_nil summary[:aborted]
    assert_equal 1, results.size
    assert_equal 1, client.call_count

    resume = FakeClient.new
    runner(client: resume, apply: true).run
    assert_equal 6, results.map { |r| r["case_no"] }.uniq.size
  end

  test "알 수 없는 SCOPE는 거부한다" do
    assert_raises(ArgumentError) { runner(scope: "nope").run }
  end
end
