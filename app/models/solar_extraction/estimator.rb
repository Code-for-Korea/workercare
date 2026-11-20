# frozen_string_literal: true

module SolarExtraction
  # dry-run용 추정. 글자 수 × 토큰/글자 비율로 입력 토큰을 어림잡는다(한국어 판정서의 실측으로 교체할 값).
  # 네트워크 호출도 API 키도 필요 없다.
  class Estimator
    DEFAULTS = {
      tokens_per_char: 0.6,
      output_tokens: 300,
      price_in_per_m: 0.10,   # solar-mini4 입력 $/100만 토큰 (docs/ext/solar/solar-mini-4.md)
      price_out_per_m: 0.40,  # solar-mini4 출력
      latency_seconds: 4.0,   # 호출 하나의 응답 시간 가정
      rpm: RateLimiter::DEFAULT_RPM,
      tpm: RateLimiter::DEFAULT_TPM,
      concurrency: 1
    }.freeze

    Result = Data.define(:cases, :input_tokens, :output_tokens, :cost, :minutes, :bottleneck)

    def self.options_from_env(env = ENV)
      {
        tokens_per_char: float(env["TOKENS_PER_CHAR"], DEFAULTS[:tokens_per_char]),
        output_tokens: Integer(env["OUT_TOKENS"].presence || DEFAULTS[:output_tokens]),
        price_in_per_m: float(env["PRICE_IN"], DEFAULTS[:price_in_per_m]),
        price_out_per_m: float(env["PRICE_OUT"], DEFAULTS[:price_out_per_m]),
        latency_seconds: float(env["LATENCY"], DEFAULTS[:latency_seconds])
      }
    end

    def self.float(value, default) = value.present? ? Float(value) : default

    def initialize(**options)
      @options = DEFAULTS.merge(options)
    end

    # 호출 한 번의 입력 토큰 추정. chars는 입력 본문 글자 수, overhead_chars는 프롬프트·스키마 글자 수.
    def call_tokens(chars, overhead_chars)
      ((chars + overhead_chars) * @options[:tokens_per_char]).ceil
    end

    # 호출 한 번이 제한기에 예약할 토큰(입력 추정 + 출력 추정)
    def reserve_tokens(chars, overhead_chars)
      call_tokens(chars, overhead_chars) + @options[:output_tokens]
    end

    # char_counts: 건별 입력 글자 수 배열
    def estimate(char_counts, overhead_chars)
      cases = char_counts.size
      input_tokens = char_counts.sum { |chars| call_tokens(chars, overhead_chars) }
      output_tokens = cases * @options[:output_tokens]
      cost = (input_tokens * @options[:price_in_per_m] + output_tokens * @options[:price_out_per_m]) / 1_000_000.0
      by_latency = cases * @options[:latency_seconds] / @options[:concurrency] / 60.0
      by_rpm = cases.to_f / @options[:rpm]
      by_tpm = (input_tokens + output_tokens).to_f / @options[:tpm]
      minutes, bottleneck = { latency: by_latency, rpm: by_rpm, tpm: by_tpm }.max_by { |_, value| value }.then { |name, value| [ value, name ] }
      Result.new(cases: cases, input_tokens: input_tokens, output_tokens: output_tokens, cost: cost, minutes: minutes, bottleneck: bottleneck)
    end
  end
end
