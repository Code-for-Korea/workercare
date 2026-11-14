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

  test "at most 20 cases are sent" do
    25.times { |i| make_case(format("SUM-X%02d", i), result: "approved", year: 2020, reasoning: "근거") }

    facts = Generator.facts_for(@key)

    assert_equal 20, facts.cases.size
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
    assert_equal false, body["stream"]
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
    assert_match(/Timeout::Error/, row.reload.error_message)
  end

  test "a truncated answer (finish_reason length) is treated as invalid" do
    row = pending_row

    generator(->(*) { exaone_response(valid_output, finish_reason: "length") }).generate(row)

    assert row.reload.failed?
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
end
