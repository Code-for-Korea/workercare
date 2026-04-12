# frozen_string_literal: true

module PIIMasking
  PII_PATTERNS = {
    resident_registration: /\d{6}-\d{7}/,
    phone_number: /\d{3}-\d{3,4}-\d{4}/,
    email: /[\w.+-]+@[\w.-]+\.\w+/,
    bank_account: /\d{4}-\d{4}-\d{4}-\d{4}/
  }.freeze

  def self.mask(text)
    return text if text.blank?

    masked = text.dup
    PII_PATTERNS.each do |name, pattern|
      masked.gsub!(pattern) do |match|
        Rails.logger.warn("[PIIMasking] Detected #{name}: #{match[0..2]}***")
        "***"
      end
    end
    masked
  end
end
