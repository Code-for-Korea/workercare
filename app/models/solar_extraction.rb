# frozen_string_literal: true

# Upstage Solar LLM으로 판정서에서 추가 항목을 뽑는 도구 모음(docs/solar-extraction-plan.md).
# DB에는 쓰지 않는다(disease_cases 읽기만). 결과는 storage/exports/solar/ 아래 JSONL로 둔다.
# 오류 메시지에는 판정서 원문이나 모델 출력 조각을 넣지 않는다(로그·failures.jsonl로 나가므로).
module SolarExtraction
  class Error < StandardError; end

  # UPSTAGE_API_KEY가 없다.
  class MissingApiKey < Error
    def initialize(msg = "UPSTAGE_API_KEY가 설정돼 있지 않습니다")
      super
    end
  end

  # 429(한도 초과)·5xx·타임아웃으로 재시도를 모두 썼다.
  class RetriesExhausted < Error
    attr_reader :attempts, :last_error

    def initialize(attempts:, last_error:)
      @attempts = attempts
      @last_error = last_error
      super("재시도 #{attempts}회 소진 (마지막 오류: #{last_error})")
    end
  end

  # 재시도해도 소용없는 4xx(429 중 usage_limit_exceeded 포함).
  class ClientError < Error
    attr_reader :status, :code

    def initialize(status:, code:)
      @status = status
      @code = code
      super("HTTP #{status} (code=#{code || '-'})")
    end
  end

  # 2xx인데 쓸 수 없는 응답(길이 초과로 잘림, JSON 아님 등). 모델 출력 조각은 메시지에 넣지 않는다.
  class InvalidResponse < Error; end
end
