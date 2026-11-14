# frozen_string_literal: true

require "test_helper"

class SelfCareForm::SummaryGeneratorTest < ActiveSupport::TestCase
  Generator = SelfCareForm::SummaryGenerator
  Key = Generator::Key

  setup do
    @a = make_case("SUM-A", result: "approved", year: 2024, reasoning: "손목을 반복해서 사용한 업무가 원인으로 판단됨")
    @b = make_case("SUM-B", result: "rejected", year: 2023, reasoning: "업무 강도가 낮아 관련성이 낮다고 판단됨", relevance: "낮음")
    @c = make_case("SUM-C", result: "approved", year: 2022, reasoning: nil, relevance: nil, committee: "위원회는 반복 작업을 인정하였다.", aggravating: nil)
    @key = Key.new(body_concept: "손목", job: "택배기사", decision: "")
  end

  def make_case(case_no, result:, year:, reasoning: nil, relevance: "높음", committee: nil, aggravating: "야간 근무")
    DiseaseCase.create!(case_no: case_no, disease_name: "손목터널증후군", job_name: "택배원", burden_body_part: "손목",
      result: result, year: year, main_reasoning: reasoning, work_relevance_eval: relevance, aggravating_factors: aggravating,
      heavy_lifting: "Y", bad_posture: "반복 굴곡", max_item_weight: 20, work_type: "상용", job_tenure_months: 36,
      committee_decision: committee, applicant_claim: "SECRET-CLAIM", job_description: "SECRET-JOB-DESC")
  end

  def valid_output(case_nos = %w[SUM-A])
    {
      "recognized_reasons" => [ { "text" => "손목을 반복해서 쓴 일이 원인으로 판단된 사례가 있습니다.", "case_nos" => case_nos } ],
      "rejected_reasons" => [ { "text" => "일의 강도가 낮다고 본 사례가 있습니다.", "case_nos" => [ "SUM-B" ] } ],
      "check_items" => [ { "text" => "무거운 물건을 다뤘는지 살폈습니다.", "case_nos" => [ "SUM-A", "SUM-B" ] } ],
      "glossary" => [ { "term" => "손목터널증후군", "meaning" => "손목 신경이 눌려 저리고 아픈 병입니다." } ]
    }
  end

  def pending_row(facts = Generator.facts_for(@key))
    SelfCareSummary.claim(@key, facts.digest).first
  end

  # ---- 사실 ----

  test "facts use the same conditions: count, distribution and factor columns of the cases" do
    facts = Generator.facts_for(@key)

    assert_equal 3, facts.total_count
    refute facts.capped
    assert_equal({ "인정" => 2, "불인정" => 1 }, facts.distribution)
    assert_equal %w[SUM-A SUM-B SUM-C], facts.case_nos # 최신 연도 순
    first = facts.cases.first
    assert_equal "야간 근무", first["가중요인"]
    assert_equal "Y", first["중량물취급"]
    assert_equal 20.0, first["최대중량_kg"]
    assert_equal 36, first["근속_개월"]
    assert_equal "높음", first["업무관련성평가"]
    assert_equal 64, facts.digest.size
  end

  test "facts never include user free text, applicant claim or job description" do
    json = Generator.facts_for(@key).prompt_hash.to_json

    assert_no_match(/SECRET/, json)
    assert_equal %w[body_concept job decision], Key.members.map(&:to_s)
  end

  test "committee decision is excerpted only for cases whose factor columns are all empty" do
    cases = Generator.facts_for(@key).cases.index_by { |c| c["사건번호"] }

    assert_nil cases["SUM-A"]["위원회판단_발췌"]
    assert_equal "위원회는 반복 작업을 인정하였다.", cases["SUM-C"]["위원회판단_발췌"]
  end

  test "at most 6 cases are sent" do
    25.times { |i| make_case(format("SUM-X%02d", i), result: "approved", year: 2020, reasoning: "근거") }

    facts = Generator.facts_for(@key)

    assert_equal 6, facts.cases.size
    assert_equal 28, facts.total_count
  end

  test "facts are nil when nothing matches and the digest changes when the data changes" do
    assert_nil Generator.facts_for(Key.new(body_concept: "손목", job: "교사", decision: ""))

    before = Generator.facts_for(@key).digest
    @a.update!(main_reasoning: "다른 근거")

    assert_not_equal before, Generator.facts_for(@key).digest
  end

  test "a key is valid only with dictionary concepts and a decision value" do
    assert @key.valid?
    assert Key.new(body_concept: "", job: "택배기사", decision: "rejected").valid?
    refute Key.new(body_concept: "", job: "", decision: "").valid?
    refute Key.new(body_concept: "내 손목이 아파요", job: "", decision: "").valid?
    refute Key.new(body_concept: "손목", job: "용접 일해요", decision: "").valid?
    refute Key.new(body_concept: "손목", job: "", decision: "all").valid?
    assert_raises(ArgumentError) { Generator.facts_for(Key.new(body_concept: "자유 입력", job: "", decision: "")) }
  end

  test "Key.for uses the relaxed conditions and refuses an unmatched free-text job" do
    answers = SelfCareForm::Answers.new("body_part" => "손목", "job" => "택배기사", "decision" => "rejected")
    result = SelfCareForm::CaseFinder.new(answers.search_conditions).call # 불인정 택배원 손목: SUM-B는 어깨가 아니라 손목이라 1건
    key = Key.for(answers, result)

    assert_equal Key.new(body_concept: "손목", job: "택배기사", decision: "rejected"), key

    typed = SelfCareForm::Answers.new("body_part" => "손목", "job_text" => "배원") # 직접 입력 LIKE로는 찾지만 사전에는 없다
    assert_nil Key.for(typed, SelfCareForm::CaseFinder.new(typed.search_conditions).call), "사전에 없는 직접 입력 직업은 요약하지 않는다"

    dropped = SelfCareForm::Answers.new("body_part" => "손목", "job_text" => "우주 비행사") # 결과가 없어 직업 조건이 빠진 경우
    assert_equal Key.new(body_concept: "손목", job: "", decision: ""), Key.for(dropped, SelfCareForm::CaseFinder.new(dropped.search_conditions).call)

    matched = SelfCareForm::Answers.new("body_part" => "손목", "job_text" => "택배원")
    matched_key = Key.for(matched, SelfCareForm::CaseFinder.new(matched.search_conditions).call)
    assert_equal "택배기사", matched_key&.job, "사전에서 찾은 직종은 개념 이름으로 요약한다"
  end

  # ---- 검사 ----

  test "validation accepts a well-formed output and normalizes it" do
    out = Generator.validate!(valid_output, %w[SUM-A SUM-B SUM-C])

    assert_equal %w[recognized_reasons rejected_reasons check_items glossary], out.keys
    assert_equal [ "SUM-A" ], out["recognized_reasons"].first["case_nos"]
  end

  test "validation rejects every forbidden phrase" do
    Generator::FORBIDDEN_PHRASES.each do |phrase|
      output = valid_output
      output["recognized_reasons"][0]["text"] = "이 일은 #{phrase} 같은 말을 담고 있습니다."

      error = assert_raises(Generator::InvalidOutput, "#{phrase}를 거르지 못함") { Generator.validate!(output, %w[SUM-A SUM-B]) }
      assert_match(/금지 표현/, error.message)
    end
    %w[인정될 가능성 유리 불리 신청하세요 승소].each do |word|
      assert Generator::FORBIDDEN_PHRASES.any? { |phrase| word.start_with?(phrase) || phrase.start_with?(word) }, "#{word} 계열이 목록에 없음"
    end
  end

  test "validation also checks the glossary text and does not block words like glass" do
    output = valid_output
    output["glossary"][0]["meaning"] = "승소할 수 있다는 뜻"
    assert_raises(Generator::InvalidOutput) { Generator.validate!(output, %w[SUM-A SUM-B]) }

    output = valid_output
    output["recognized_reasons"][0]["text"] = "유리 공장에서 일한 사례가 있습니다."
    assert Generator.validate!(output, %w[SUM-A SUM-B])
  end

  test "validation rejects a case_no that is not in the input" do
    error = assert_raises(Generator::InvalidOutput) { Generator.validate!(valid_output(%w[SUM-A NOPE-1]), %w[SUM-A SUM-B]) }
    assert_match(/입력에 없는 사건번호/, error.message)
  end

  test "validation rejects wrong shapes" do
    bad = [
      "text",
      {},
      valid_output.merge("recognized_reasons" => "x"),
      valid_output.merge("recognized_reasons" => [ { "text" => "문장", "case_nos" => [] } ]),
      valid_output.merge("recognized_reasons" => [ { "text" => "문장", "case_nos" => %w[SUM-A SUM-B SUM-C SUM-A2] } ]),
      valid_output.merge("recognized_reasons" => [ { "text" => "", "case_nos" => %w[SUM-A] } ]),
      valid_output.merge("recognized_reasons" => [ { "text" => "가" * 301, "case_nos" => %w[SUM-A] } ]),
      valid_output.merge("check_items" => Array.new(6) { { "text" => "문장", "case_nos" => %w[SUM-A] } }),
      valid_output.merge("glossary" => [ { "term" => "용어" } ])
    ]
    bad.each do |output|
      assert_raises(Generator::InvalidOutput, output.inspect) { Generator.validate!(output, %w[SUM-A SUM-B SUM-C SUM-A2]) }
    end
  end

  # ---- 생성(스텁 전송) ----

  def generator(transport, **options)
    Generator.new(transport: transport, api_key: "test-key-not-real", sleeper: ->(_) { }, min_interval: 0, **options)
  end

  test "generate saves a ready summary with the meta and sends the documented request" do
    seen = []
    transport = lambda do |uri, headers, body|
      seen << [ uri, headers, JSON.parse(body) ]
      exaone_response(valid_output(%w[SUM-A]))
    end
    row = pending_row

    generator(transport).generate(row)

    row.reload
    assert row.ready?
    assert_equal Generator::MODEL, row.model
    assert_equal Generator::PROMPT_VERSION, row.prompt_version
    assert_not_nil row.generated_at
    assert_equal 3, row.summary_json.dig("meta", "shown_count")
    assert_equal "SUM-A", row.summary_json["recognized_reasons"].first["case_nos"].first

    uri, headers, body = seen.first
    assert_equal "https://api.exaone.ai/v1/chat/completions", uri.to_s
    assert_equal "Bearer test-key-not-real", headers["Authorization"]
    assert_equal "k-exaone_v2.5", body["model"]
    assert_equal true, body["stream"]
    assert_equal %w[system user], body["messages"].map { |m| m["role"] }
    refute_match(/SECRET/, body["messages"].to_json)
    assert_match(/사건번호/, body["messages"].last["content"])
  end

  test "an output that fails validation is retried once, then the row is failed with the error" do
    calls = 0
    transport = lambda do |*|
      calls += 1
      exaone_response(valid_output(%w[NOPE-9]))
    end
    row = pending_row

    generator(transport).generate(row)

    assert_equal Generator::MAX_OUTPUT_ATTEMPTS, calls
    row.reload
    assert row.failed?
    assert_match(/입력에 없는 사건번호/, row.error_message)
    assert_nil row.summary_json
  end

  test "the second attempt can succeed after an invalid first output" do
    outputs = [ "JSON 아님", valid_output ]
    transport = ->(*) { exaone_response(outputs.shift) }
    row = pending_row

    generator(transport).generate(row)

    assert row.reload.ready?
  end

  test "a fenced json answer is parsed" do
    transport = ->(*) { exaone_response("```json\n#{valid_output.to_json}\n```") }
    row = pending_row

    generator(transport).generate(row)

    assert row.reload.ready?
  end

  test "429 waits for retry-after and tries again" do
    sleeps = []
    responses = [ exaone_response({ result_code: 429 }, code: 429, headers: { "retry-after" => "2", "retry-after-ms" => "630" }),
                  exaone_response(valid_output) ]
    row = pending_row

    Generator.new(transport: ->(*) { responses.shift }, api_key: "k", sleeper: ->(s) { sleeps << s }, min_interval: 0).generate(row)

    assert row.reload.ready?
    assert_equal [ 0.63 ], sleeps
  end

  test "repeated 429 fails the row without leaking the key" do
    transport = ->(*) { exaone_response({ result_code: 429, description: "too many" }, code: 429, headers: { "retry-after" => "1" }) }
    row = pending_row

    generator(transport).generate(row)

    assert row.reload.failed?
    assert_match(/HTTP 429/, row.error_message)
    refute_match(/test-key-not-real/, row.error_message)
  end

  test "a 401 is not retried" do
    calls = 0
    row = pending_row

    generator(->(*) { calls += 1; exaone_response({ result_code: 401, description: "bad key" }, code: 401) }).generate(row)

    assert_equal 1, calls
    assert_match(/HTTP 401/, row.reload.error_message)
  end

  test "a transport error marks the row failed instead of raising" do
    row = pending_row

    assert_nothing_raised { generator(->(*) { raise Timeout::Error, "slow" }).generate(row) }
    assert_match(/RequestTimeout.*시간 초과/, row.reload.error_message)
  end

  test "a truncated answer (finish_reason length) fails the row without a second request" do
    row = pending_row
    calls = 0

    generator(->(*) { calls += 1; exaone_response(valid_output, finish_reason: "length") }).generate(row)

    assert_equal 1, calls
    assert row.reload.failed?
    assert_match(/Truncated.*응답이 잘림/, row.error_message)
  end

  test "a timeout is not retried and says so" do
    calls = 0
    row = pending_row

    generator(->(*) { calls += 1; raise Net::ReadTimeout }).generate(row)

    assert_equal 1, calls
    assert_match(/시간 초과/, row.reload.error_message)
  end

  test "a complete answer that fails validation is still retried once" do
    calls = 0
    generator(->(*) { calls += 1; exaone_response("JSON 아님") }).generate(pending_row)

    assert_equal Generator::MAX_OUTPUT_ATTEMPTS, calls
  end

  test "limits default to 7000 tokens, 600s total and 120s per chunk and can be overridden by env" do
    assert_equal [ 7000, 600, 120 ], [ Generator.max_tokens, Generator.total_timeout, Generator.chunk_timeout ]
    ENV["EXAONE_MAX_TOKENS"] = "5000"
    ENV["EXAONE_TOTAL_TIMEOUT"] = "300"
    ENV["EXAONE_CHUNK_TIMEOUT"] = "bad"
    assert_equal [ 5000, 300, 120 ], [ Generator.max_tokens, Generator.total_timeout, Generator.chunk_timeout ]
    body = Generator.new(api_key: "k").send(:request_body, Generator.facts_for(@key))
    assert_equal 5000, body[:max_tokens]
  ensure
    %w[EXAONE_MAX_TOKENS EXAONE_TOTAL_TIMEOUT EXAONE_CHUNK_TIMEOUT].each { |name| ENV.delete(name) }
  end

  test "call duration and usage are stored in meta.generation" do
    body = { choices: [ { finish_reason: "stop", message: { content: valid_output.to_json } } ],
             usage: { prompt_tokens: 100, completion_tokens: 900, reasoning_tokens: 700, total_tokens: 1000 } }.to_json
    row = pending_row

    generator(->(*) { OffExaoneByDefault::FakeExaoneResponse.new("200", body, nil) }).generate(row)

    generation = row.reload.summary_json.dig("meta", "generation")
    assert_equal({ "prompt_tokens" => 100, "completion_tokens" => 900, "reasoning_tokens" => 700, "finish_reason" => "stop" }, generation.except("seconds"))
    assert_kind_of Numeric, generation["seconds"]
  end

  test "without an api key nothing is sent" do
    row = pending_row

    Generator.new(transport: ->(*) { flunk "호출하면 안 됨" }, sleeper: ->(_) { }, min_interval: 0).generate(row)

    assert_match(/EXAONE_API_KEY/, row.reload.error_message)
  end

  test "a changed digest fails the row instead of saving a stale summary" do
    row = SelfCareSummary.claim(@key, "0" * 64).first

    generator(->(*) { flunk "호출하면 안 됨" }).generate(row)

    assert_match(/지문/, row.reload.error_message)
  end

  test "the throttle waits for the minimum interval between requests" do
    sleeps = []
    gen = Generator.new(transport: ->(*) { exaone_response(valid_output) }, api_key: "k", sleeper: ->(s) { sleeps << s }, min_interval: 1.1)
    Generator.last_request_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    gen.generate(pending_row)

    assert_equal 1, sleeps.size
    assert_operator sleeps.first, :>, 0.5
  end

  test "enabled? needs both the flag and the key" do
    refute Generator.enabled?
    with_exaone(enabled: false)
    refute Generator.enabled?
    ENV["EXAONE_SUMMARY_ENABLED"] = "true"
    assert Generator.enabled?
    ENV.delete("EXAONE_API_KEY")
    refute Generator.enabled?
  end

  test "claim creates one row per condition and digest" do
    first, created = SelfCareSummary.claim(@key, "a" * 64)
    again, created_again = SelfCareSummary.claim(@key, "a" * 64)
    other, = SelfCareSummary.claim(@key, "b" * 64)

    assert created
    refute created_again
    assert_equal first, again
    assert_not_equal first, other
    assert_raises(ActiveRecord::RecordNotUnique) do
      SelfCareSummary.create!(body_concept: "손목", job: "택배기사", decision: "", data_digest: "a" * 64)
    end
  end

  test "warm combinations rank by case count and skip empty ones" do
    combos = SelfCareSummaries::Warm.combinations(10)

    assert_equal 3, combos.first.facts.total_count
    assert combos.all? { |c| c.key.decision.empty? && c.key.valid? }
    assert_equal 1, SelfCareSummaries::Warm.combinations(1).size
  end

  # ---- v2: 429 재시도, 하루 예산, 스트리밍, overview ----

  def with_memory_cache
    saved = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    yield
  ensure
    Rails.cache = saved
  end

  def busy_response
    body = { error: { message: "service is busy, too many concurrent requests(600)", type: "rate_limit_error" } }.to_json
    OffExaoneByDefault::FakeExaoneResponse.new("429", body, nil)
  end

  test "a busy 429 without retry-after backs off 15, 30 and 60 seconds and then succeeds" do
    sleeps = []
    responses = [ busy_response, busy_response, busy_response, exaone_response(valid_output) ]
    row = pending_row

    with_memory_cache do
      Generator.new(transport: ->(*) { responses.shift }, api_key: "k", sleeper: ->(s) { sleeps << s }, min_interval: 0).generate(row)
    end

    assert row.reload.ready?
    assert_equal [ 15, 30, 60 ], sleeps
  end

  test "a busy 429 that never clears fails the row after three retries with a clear message" do
    calls = 0
    sleeps = []
    row = pending_row

    with_memory_cache do
      Generator.new(transport: ->(*) { calls += 1; busy_response }, api_key: "k", sleeper: ->(s) { sleeps << s }, min_interval: 0).generate(row)
    end

    assert_equal 4, calls
    assert_equal [ 15, 30, 60 ], sleeps
    assert row.reload.failed?
    assert_match(/HTTP 429.*service is busy.*재시도 3회/, row.error_message)
  end

  test "busy retries are not counted as output validation attempts" do
    outputs = [ busy_response, busy_response, exaone_response("JSON 아님"), exaone_response(valid_output) ]
    row = pending_row

    with_memory_cache do
      generator(->(*) { outputs.shift }).generate(row)
    end

    assert row.reload.ready?
  end

  test "every request including 429s counts toward the daily budget" do
    responses = [ busy_response, exaone_response(valid_output) ]
    with_memory_cache do
      generator(->(*) { responses.shift }).generate(pending_row)

      assert_equal 2, SelfCareForm::ExaoneBudget.used
    end
  end

  test "when the daily cap is reached the API is not called and the row records the budget failure" do
    row = pending_row
    ENV["EXAONE_DAILY_REQUEST_CAP"] = "2"
    with_memory_cache do
      2.times { SelfCareForm::ExaoneBudget.record_request! }
      refute SelfCareForm::ExaoneBudget.available?

      generator(->(*) { flunk "호출하면 안 됨" }).generate(row)
    end

    assert row.reload.budget_failure?
  ensure
    ENV.delete("EXAONE_DAILY_REQUEST_CAP")
  end

  test "the cap defaults to 28,800 and an invalid value falls back to it" do
    assert_equal 28_800, SelfCareForm::ExaoneBudget.cap
    ENV["EXAONE_DAILY_REQUEST_CAP"] = "abc"
    assert_equal 28_800, SelfCareForm::ExaoneBudget.cap
    ENV["EXAONE_DAILY_REQUEST_CAP"] = "40"
    assert_equal 40, SelfCareForm::ExaoneBudget.cap
  ensure
    ENV.delete("EXAONE_DAILY_REQUEST_CAP")
  end

  test "a response header showing five or fewer requests left stops further calls today" do
    with_memory_cache do
      calls = 0
      transport = lambda do |*|
        calls += 1
        exaone_response("JSON 아님", headers: { "x-day-rate-limit-remaining" => "5" })
      end
      row = pending_row

      generator(transport).generate(row)

      assert_equal 1, calls # 두 번째 출력 시도 전에 멈춘다
      assert_match(/BudgetExhausted/, row.reload.error_message)
      assert_equal 5, SelfCareForm::ExaoneBudget.remaining_hint
    end
  end

  test "the budget counter and header hint are per day" do
    with_memory_cache do
      SelfCareForm::ExaoneBudget.record_request!
      travel_to 1.day.from_now do
        assert_equal 0, SelfCareForm::ExaoneBudget.used
      end
    end
  end

  test "streamed chunks are assembled: only delta.content is kept and usage is logged" do
    sse = [
      %(data: {"choices":[{"delta":{"content":"","role":"assistant"},"index":0}]}\n\n),
      %(data: {"choices":[{"delta":{"reasoning_content":"생각"},"index":0}]}\n\ndata: {"choices":[{"delta":{"con),
      %(tent":"{\\"a\\":1}"},"index":0}]}\n\n),
      %(data: {"choices":[{"delta":{},"finish_reason":"stop","index":0}]}\n\n),
      %(data: {"choices":[],"usage":{"completion_tokens":9,"prompt_tokens":4,"total_tokens":13,"reasoning_tokens":5}}\n\ndata: [DONE]\n)
    ]
    response = Object.new
    response.define_singleton_method(:read_body) { |&block| sse.each { |chunk| block.call(chunk.dup) } }
    log = StringIO.new
    gen = Generator.new(api_key: "k", logger: Logger.new(log), sleeper: ->(_) { }, min_interval: 0)

    body = gen.send(:read_stream, response, Process.clock_gettime(Process::CLOCK_MONOTONIC))
    content = gen.send(:extract_content, body)

    assert_equal %({"a":1}), content
    assert_match(/prompt=4 completion=9 reasoning=5 total=13/, log.string)
    refute_match(/생각/, log.string)
  end

  test "a stream that runs past the total timeout raises" do
    response = Object.new
    response.define_singleton_method(:read_body) { |&block| block.call(%(data: {"choices":[]}\n).dup) }
    gen = Generator.new(api_key: "k", sleeper: ->(_) { }, min_interval: 0)

    assert_raises(Timeout::Error) do
      gen.send(:read_stream, response, Process.clock_gettime(Process::CLOCK_MONOTONIC) - Generator.total_timeout - 1)
    end
  end

  test "the v2 prompt asks for the distribution, no duplicate citations, and literal check items" do
    messages = Generator.new(api_key: "k").messages_for(Generator.facts_for(@key))
    text = messages.map { |m| m[:content] }.join

    assert_equal "v3", Generator::PROMPT_VERSION
    assert_match(/최대 3개/, text)
    assert_match(/같은 사건번호를 두 항목 이상에 쓰지 않습니다/, text)
    assert_match(/질병군_분포/, text)
    assert_match(/여러 질병이 섞여 있습니다/, text)
    assert_match(/덧붙이지 않습니다/, text)
  end

  test "facts carry the disease category distribution and the number of disease kinds, not name lists" do
    DiseaseCase.where(case_no: "SUM-C").update_all(disease_category: "cardiovascular", disease_name: "뇌경색")
    DiseaseCase.where(case_no: %w[SUM-A SUM-B]).update_all(disease_category: "musculoskeletal")
    facts = Generator.facts_for(@key)

    assert_equal({ "근골격계질병" => 2, "뇌심혈관계질병" => 1 }, facts.diseases[:categories])
    assert_equal 2, facts.diseases[:kinds]
    assert_equal({ "근골격계질병" => 2, "뇌심혈관계질병" => 1 }, facts.prompt_hash["질병군_분포"])
    assert_equal 2, facts.prompt_hash["질병_종류_수"]
    assert_nil facts.prompt_hash["질병명_분포_상위"]
  end

  test "a missing category is reported as unclassified" do
    assert_equal({ "미분류" => 3 }, Generator.facts_for(@key).diseases[:categories])
  end

  test "overview is validated, kept and checked for forbidden phrases" do
    out = Generator.validate!(valid_output.merge("overview" => "찾은 3건입니다."), %w[SUM-A SUM-B])
    assert_equal "찾은 3건입니다.", out["overview"]

    assert_raises(Generator::InvalidOutput) { Generator.validate!(valid_output.merge("overview" => "인정될 것입니다."), %w[SUM-A SUM-B]) }
    assert_raises(Generator::InvalidOutput) { Generator.validate!(valid_output.merge("overview" => 3), %w[SUM-A SUM-B]) }
  end

  test "more than three items in a section is invalid" do
    items = Array.new(4) { { "text" => "문장", "case_nos" => %w[SUM-A] } }

    assert_raises(Generator::InvalidOutput) { Generator.validate!(valid_output.merge("check_items" => items), %w[SUM-A SUM-B]) }
  end

  test "warm combinations need a body part by default" do
    assert SelfCareSummaries::Warm.combinations(10).all? { |c| c.key.body_concept.present? }
    assert SelfCareSummaries::Warm.combinations(10, require_body: false).any? { |c| c.key.body_concept.empty? }
  end
end
