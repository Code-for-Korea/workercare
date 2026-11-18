# frozen_string_literal: true

require "test_helper"

class SolarExtraction::ClientTest < ActiveSupport::TestCase
  class FakeTransport
    attr_reader :calls

    def initialize(*responses)
      @responses = responses
      @calls = []
    end

    def call(uri, headers, body)
      @calls << { uri: uri, headers: headers, body: JSON.parse(body) }
      response = @responses.size > 1 ? @responses.shift : @responses.first
      raise response if response.is_a?(Class) && response < Exception

      response
    end
  end

  def ok_body(content: { "a" => 1 }, finish: "stop", reasoning: 0)
    JSON.generate(
      model: "solar-mini4-260922",
      choices: [ { index: 0, finish_reason: finish, message: { role: "assistant", content: JSON.generate(content) } } ],
      usage: { prompt_tokens: 100, completion_tokens: 20, total_tokens: 120, completion_tokens_details: { reasoning_tokens: reasoning } }
    )
  end

  def error_body(code) = JSON.generate(error: { message: "x", type: "t", param: "", code: code })

  def build(transport, **options)
    @sleeps = []
    SolarExtraction::Client.new(api_key: "test-key", transport: transport, sleeper: ->(s) { @sleeps << s }, random: Random.new(1),
                                wall_clock: -> { 1_000.0 }, reasoning_effort: "none", **options)
  end

  def extract(client)
    client.extract(messages: [ { role: "user", content: "hi" } ], schema_name: "t", schema: { type: "object" }, estimated_tokens: 50)
  end

  test "요청 형태와 인증 헤더, 응답 파싱" do
    transport = FakeTransport.new([ 200, {}, ok_body(reasoning: 7) ])
    response = extract(build(transport, model: "solar-mini4"))

    call = transport.calls.first
    assert_equal "https://api.upstage.ai/v1/chat/completions", call[:uri].to_s
    assert_equal "Bearer test-key", call[:headers]["Authorization"]
    body = call[:body]
    assert_equal "solar-mini4", body["model"]
    assert_equal 0, body["temperature"]
    assert_equal "none", body["reasoning_effort"]
    assert_equal "json_schema", body.dig("response_format", "type")
    assert_equal true, body.dig("response_format", "json_schema", "strict")
    assert_equal "t", body.dig("response_format", "json_schema", "name")
    assert_equal({ "a" => 1 }, response.content)
    assert_equal({ prompt_tokens: 100, completion_tokens: 20, reasoning_tokens: 7, total_tokens: 120 }, response.usage)
    assert_equal "solar-mini4-260922", response.model
    assert_equal 1, response.attempts
  end

  test "모델 기본값은 SOLAR_MODEL 또는 solar-mini4" do
    transport = FakeTransport.new([ 200, {}, ok_body ])
    original = ENV["SOLAR_MODEL"]
    ENV["SOLAR_MODEL"] = nil
    assert_equal "solar-mini4", build(transport).model
    ENV["SOLAR_MODEL"] = "custom-model"
    assert_equal "custom-model", build(transport).model
  ensure
    ENV["SOLAR_MODEL"] = original
  end

  test "429 뒤 성공하면 재시도하고 Retry-After 헤더를 따른다" do
    transport = FakeTransport.new(
      [ 429, { "X-Upstage-RateLimit-Retry-After-Tokens" => "1030" }, error_body("too_many_requests") ],
      [ 200, {}, ok_body ]
    )
    response = extract(build(transport))

    assert_equal 2, transport.calls.size
    assert_equal 2, response.attempts
    assert_equal 1, @sleeps.size
    assert_in_delta 30.0, @sleeps.first, 0.001 # 헤더(1030) - 현재(1000)가 백오프(1~2초)보다 크다
  end

  test "5xx와 타임아웃도 재시도하고 소진하면 RetriesExhausted" do
    transport = FakeTransport.new([ 503, {}, "" ], Net::ReadTimeout)
    error = assert_raises(SolarExtraction::RetriesExhausted) { extract(build(transport, max_attempts: 3)) }

    assert_equal 3, transport.calls.size
    assert_equal 3, error.attempts
    assert_equal 2, @sleeps.size # 마지막 시도 뒤에는 기다리지 않는다
    assert_match(/network:Net::ReadTimeout/, error.last_error)
  end

  test "백오프는 지수로 늘고 상한을 넘지 않는다" do
    transport = FakeTransport.new([ 500, {}, "" ])
    assert_raises(SolarExtraction::RetriesExhausted) { extract(build(transport, max_attempts: 4, base_delay: 2.0, max_delay: 5.0)) }

    assert_equal 3, @sleeps.size
    assert_includes 1.0..2.0, @sleeps[0]
    assert_includes 2.0..4.0, @sleeps[1]
    assert_includes 2.5..5.0, @sleeps[2]
  end

  test "429가 아닌 4xx는 재시도하지 않는다" do
    transport = FakeTransport.new([ 401, {}, error_body("invalid_api_key") ])
    error = assert_raises(SolarExtraction::ClientError) { extract(build(transport)) }

    assert_equal 1, transport.calls.size
    assert_equal 401, error.status
    assert_equal "invalid_api_key", error.code
    assert_empty @sleeps
  end

  test "usage_limit_exceeded(429)는 재시도하지 않는다" do
    transport = FakeTransport.new([ 429, {}, error_body("usage_limit_exceeded") ])
    assert_raises(SolarExtraction::ClientError) { extract(build(transport)) }
    assert_equal 1, transport.calls.size
  end

  test "길이 초과로 잘린 응답과 JSON이 아닌 content는 InvalidResponse" do
    assert_raises(SolarExtraction::InvalidResponse) { extract(build(FakeTransport.new([ 200, {}, ok_body(finish: "length") ]))) }
    broken = JSON.generate(choices: [ { finish_reason: "stop", message: { content: "not json" } } ])
    error = assert_raises(SolarExtraction::InvalidResponse) { extract(build(FakeTransport.new([ 200, {}, broken ]))) }
    assert_no_match(/not json/, error.message)
  end

  test "키가 없으면 MissingApiKey" do
    assert_raises(SolarExtraction::MissingApiKey) { SolarExtraction::Client.new(api_key: nil, transport: FakeTransport.new) }
    assert_raises(SolarExtraction::MissingApiKey) { SolarExtraction::Client.new(api_key: "", transport: FakeTransport.new) }
  end

  test "제한기를 주면 시도마다 예약하고 실제 사용량으로 보정한다" do
    limiter = SolarExtraction::RateLimiter.new(rpm: 10, tpm: 1000, sleeper: ->(_) { flunk "기다리면 안 됩니다" })
    transport = FakeTransport.new([ 200, {}, ok_body ])
    extract(build(transport, limiter: limiter))

    assert_equal [ 1, 120 ], limiter.usage
  end
end
