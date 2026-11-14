# frozen_string_literal: true

module SelfCareForm
  # config/self_care_form.yml을 읽고 검증한다. 서버가 이 URL을 호출하므로 아래를 모두 확인하고, 하나라도 어긋나면
  # 전송을 끈다(요청 파라미터로 URL이나 id를 바꿀 수 없다).
  #   ① https ② 호스트가 정확히 docs.google.com ③ 경로 /forms/d/e/<ID>/formResponse ④ 쿼리·프래그먼트 없음
  #   ⑤ entries의 키는 Flow::SENDABLE_KEYS 중에서만, 값은 숫자만
  class Settings
    PATH = Rails.root.join("config/self_care_form.yml")
    HOST = "docs.google.com"
    PATH_PATTERN = %r{\A/forms/d/e/[\w-]+/formResponse\z}
    ID_PATTERN = /\A\d+\z/

    attr_reader :url, :entries, :errors

    class << self
      def current
        @current ||= load(PATH)
      end

      # 테스트에서 설정을 바꿔 끼운다(nil이면 파일에서 다시 읽는다).
      attr_writer :current

      def reset!
        @current = nil
      end

      def load(path)
        raw = File.exist?(path) ? (YAML.safe_load_file(path) || {}) : {}
        new(enabled: raw["enabled"] == true, url: raw["google_form_response_url"], entries: raw["entries"])
      end
    end

    def initialize(enabled:, url:, entries:)
      @enabled = enabled
      @url = url.to_s
      @entries = (entries.is_a?(Hash) ? entries : {}).to_h { |k, v| [ k.to_s, v.to_s ] }
      @errors = validate
    end

    # 설정만 올바르면 true(enabled 여부와 무관). send_test가 쓴다.
    def valid?
      @errors.empty? && @entries.any?
    end

    # 켜져 있고 설정이 올바를 때만 true. 이때만 전송하고 선택 동의란을 보여 준다.
    def enabled?
      @enabled && valid?
    end

    def uri
      URI.parse(@url)
    end

    # enabled: true인데 검증에 실패했을 때 부팅 로그로 알린다(값은 적지 않는다).
    def warn_if_invalid(logger = Rails.logger)
      return unless @enabled && !valid?

      reasons = @entries.empty? && @errors.empty? ? [ "entries가 비어 있음" ] : @errors
      logger.warn("[self_care_form] 구글 폼 전송이 꺼졌습니다: #{reasons.join(', ')}")
    end

    private

    def validate
      problems = []
      return problems if @url.empty? && @entries.empty? && !@enabled # 기본(꺼짐, 값 없음)은 오류가 아니다

      problems.concat(validate_url)
      unknown = @entries.keys - Flow::SENDABLE_KEYS
      problems << "알 수 없는 entries 키" if unknown.any?
      problems << "entries 값이 숫자가 아님" unless @entries.values.all? { |v| v.match?(ID_PATTERN) }
      problems
    end

    def validate_url
      parsed = URI.parse(@url)
      problems = []
      problems << "https가 아님" unless parsed.scheme == "https"
      problems << "호스트가 #{HOST}가 아님" unless parsed.host == HOST
      problems << "경로가 formResponse 형식이 아님" unless parsed.path.to_s.match?(PATH_PATTERN)
      problems << "쿼리 또는 프래그먼트가 있음" if parsed.query || parsed.fragment
      problems
    rescue URI::InvalidURIError
      [ "URL 형식이 올바르지 않음" ]
    end
  end
end
