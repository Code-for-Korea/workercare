# frozen_string_literal: true

require "net/http"
require "json"

module SolarExtraction
  # Upstage Solar Chat Completions 클라이언트(structured outputs). 요청 형식은 docs/ext/solar/ 의 로컬 사본을 따른다.
  #
  # - 엔드포인트 POST https://api.upstage.ai/v1/chat/completions, 헤더 Authorization: Bearer <UPSTAGE_API_KEY>
  # - response_format: {type: "json_schema", json_schema: {name:, strict: true, schema:}} (structured-outputs.md: strict 필수 true)
  # - solar-mini4는 reasoning_effort를 생략하면 꺼져 있다(reasoning.md). 모델 갱신으로 바뀔 수 있어 기본 "none"을 명시한다.
  #   추론 토큰은 completion 토큰에 포함된다.
  # - 429·5xx·타임아웃은 지수 백오프+지터로 재시도한다. 429는 X-Upstage-RateLimit-Retry-After-* (Unix 초) 헤더를 따른다.
  #   429 중 usage_limit_exceeded(월 청구 한도)는 재시도해도 소용없으니 바로 올린다. 그 밖의 4xx도 바로 올린다.
  #   헤더 대기는 max_delay로 자르지 않고 그대로 따른다. max_header_wait(기본 900초)를 넘으면 일찍 올리지 않고 RetriesExhausted로 끝낸다.
  # - 로그를 남기지 않는다. 오류 메시지에도 요청·응답 본문을 넣지 않는다.
  class Client
    ENDPOINT = URI("https://api.upstage.ai/v1/chat/completions")
    DEFAULT_MODEL = "solar-mini4"
    RETRY_AFTER_HEADERS = %w[
      x-upstage-ratelimit-retry-after-requests
      x-upstage-ratelimit-retry-after-tokens
    ].freeze
    NETWORK_ERRORS = [
      Timeout::Error, SocketError, EOFError, IOError, SystemCallError, OpenSSL::SSL::SSLError
    ].freeze

    Response = Data.define(:content, :usage, :model, :finish_reason, :attempts)

    # transport: ->(uri, headers, body) { [status, headers, body_string] }. 기본은 Net::HTTP.
    def initialize(api_key: ENV["UPSTAGE_API_KEY"], model: nil, transport: nil, limiter: nil,
                   max_attempts: 5, base_delay: 2.0, max_delay: 120.0, max_header_wait: 900.0, max_tokens: 1500, temperature: 0,
                   reasoning_effort: ENV.fetch("SOLAR_REASONING_EFFORT", "none"),
                   open_timeout: 10, read_timeout: 180,
                   sleeper: ->(seconds) { sleep(seconds) }, random: Random.new, wall_clock: -> { Time.now.to_f })
      raise MissingApiKey if api_key.blank?

      @api_key = api_key
      @model = model.presence || ENV["SOLAR_MODEL"].presence || DEFAULT_MODEL
      @transport = transport || method(:http_post)
      @limiter = limiter
      @max_attempts = [ max_attempts.to_i, 1 ].max
      @base_delay = base_delay
      @max_delay = max_delay
      @max_header_wait = max_header_wait
      @max_tokens = max_tokens
      @temperature = temperature
      @reasoning_effort = reasoning_effort.presence
      @open_timeout = open_timeout
      @read_timeout = read_timeout
      @sleeper = sleeper
      @random = random
      @wall_clock = wall_clock
    end

    attr_reader :model

    # messages: [{role:, content:}, ...]. estimated_tokens: 제한기에 예약할 추정 토큰(프롬프트+출력).
    # @return [Response] content는 파싱된 JSON(Hash), usage는 {prompt_tokens:, completion_tokens:, reasoning_tokens:, total_tokens:}
    # max_tokens: 과제별 출력 상한(없으면 생성자 값)
    def extract(messages:, schema_name:, schema:, estimated_tokens: 0, max_tokens: nil)
      payload = JSON.generate(request_body(messages, schema_name, schema, max_tokens))
      last_error = nil

      1.upto(@max_attempts) do |attempt|
        reservation = @limiter&.acquire(estimated_tokens)
        begin
          status, headers, body = @transport.call(ENDPOINT, request_headers, payload)
        rescue *NETWORK_ERRORS => e
          last_error = "network:#{e.class}"
          pause(backoff(attempt)) if attempt < @max_attempts
          next
        end

        if status.between?(200, 299)
          response = parse_response(body, attempt)
          @limiter&.reconcile(reservation, response.usage[:total_tokens])
          return response
        end

        code = error_code(body)
        raise ClientError.new(status: status, code: code) unless retryable?(status, code)

        last_error = "http:#{status}"
        if attempt < @max_attempts
          delay = retry_delay(status, headers, attempt)
          # 헤더가 허용하는 시각 전에 재시도하면 또 429라 일찍 끝내는 편이 낫다
          raise RetriesExhausted.new(attempts: attempt, last_error: "http:#{status}:retry_after_too_long") if delay > @max_header_wait

          pause(delay)
        end
      end

      raise RetriesExhausted.new(attempts: @max_attempts, last_error: last_error)
    end

    private

    def request_body(messages, schema_name, schema, max_tokens = nil)
      body = {
        model: @model,
        messages: messages,
        max_tokens: max_tokens || @max_tokens,
        response_format: {
          type: "json_schema",
          json_schema: { name: schema_name, strict: true, schema: schema }
        }
      }
      body[:temperature] = @temperature unless @temperature.nil?
      body[:reasoning_effort] = @reasoning_effort if @reasoning_effort
      body
    end

    def request_headers
      { "Authorization" => "Bearer #{@api_key}", "Content-Type" => "application/json", "Accept" => "application/json" }
    end

    def retryable?(status, code)
      return code != "usage_limit_exceeded" if status == 429

      status >= 500 || [ 408, 499 ].include?(status)
    end

    def error_code(body)
      JSON.parse(body.to_s).dig("error", "code")
    rescue JSON::ParserError, TypeError
      nil
    end

    # 헤더가 있으면 그 시각(Unix 초)까지, 없으면 지수 백오프(max_delay 상한). 둘 중 큰 값을 쓴다.
    # 헤더 대기는 max_delay로 자르지 않는다(허용 전에 다시 보내면 안 된다). 비정상적으로 길면(max_header_wait 초과) 호출부가 포기한다.
    def retry_delay(status, headers, attempt)
      from_header = status == 429 ? header_wait(headers) : 0
      [ from_header, backoff(attempt) ].max
    end

    def header_wait(headers)
      normalized = (headers || {}).transform_keys { |key| key.to_s.downcase }
      waits = RETRY_AFTER_HEADERS.filter_map do |name|
        value = normalized[name]
        value.to_f - @wall_clock.call if value.present?
      end
      [ waits.max.to_f, 0 ].max
    end

    # 절반~전부 사이의 지터를 준 지수 백오프
    def backoff(attempt)
      delay = [ @base_delay * (2**(attempt - 1)), @max_delay ].min
      delay * (0.5 + (@random.rand * 0.5))
    end

    def pause(seconds)
      @sleeper.call(seconds) if seconds.positive?
    end

    def parse_response(body, attempt)
      data = JSON.parse(body.to_s)
      choice = data.dig("choices", 0) or raise InvalidResponse, "choices가 없습니다"
      finish = choice["finish_reason"]
      raise InvalidResponse, "finish_reason=#{finish} (출력이 잘렸습니다)" if finish == "length"

      text = choice.dig("message", "content")
      raise InvalidResponse, "message.content가 비어 있습니다" unless text.is_a?(String) && text.present?

      content = begin
        JSON.parse(text)
      rescue JSON::ParserError
        raise InvalidResponse, "content가 JSON이 아닙니다"
      end
      raise InvalidResponse, "content가 JSON 객체가 아닙니다" unless content.is_a?(Hash)

      Response.new(content: content, usage: extract_usage(data["usage"]), model: data["model"], finish_reason: finish, attempts: attempt)
    rescue JSON::ParserError
      raise InvalidResponse, "응답 본문이 JSON이 아닙니다"
    end

    def extract_usage(usage)
      usage ||= {}
      prompt = usage["prompt_tokens"].to_i
      completion = usage["completion_tokens"].to_i
      {
        prompt_tokens: prompt,
        completion_tokens: completion,
        reasoning_tokens: usage.dig("completion_tokens_details", "reasoning_tokens").to_i,
        total_tokens: usage["total_tokens"] || (prompt + completion)
      }
    end

    # 응답 헤더 이름은 소문자로 돌려준다. 리다이렉트는 따라가지 않는다.
    def http_post(uri, headers, body)
      request = Net::HTTP::Post.new(uri, headers)
      request.body = body
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: @open_timeout, read_timeout: @read_timeout) do |http|
        http.request(request)
      end
      response_headers = response.each_header.to_h { |key, value| [ key.downcase, value ] }
      [ response.code.to_i, response_headers, response.body ]
    end
  end
end
