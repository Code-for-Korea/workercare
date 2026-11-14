# frozen_string_literal: true

module PIIMasking
  PII_PATTERNS = {
    resident_registration: /\d{6}-\d{7}/,
    phone_number: /\d{3}-\d{3,4}-\d{4}/,
    email: /[\w.+-]+@[\w.-]+\.\w+/,
    bank_account: /\d{4}-\d{4}-\d{4}-\d{4}/
  }.freeze

  # log: false면 감지 사실도 로그에 남기지 않는다(입력 조각이 로그에 가면 안 되는 호출부용). 기본 동작은 그대로다.
  def self.mask(text, log: true)
    return text if text.blank?

    masked = text.dup
    PII_PATTERNS.each do |name, pattern|
      masked.gsub!(pattern) do |match|
        Rails.logger.warn("[PIIMasking] Detected #{name}: #{match[0..2]}***") if log
        "***"
      end
    end
    masked
  end
end
