# frozen_string_literal: true

module Chatbot
  # 챗봇 응답용 공개 DTO. 허용 필드만 직렬화한다(화이트리스트).
  # 비식별은 적재 단계의 책임이며, PIIMasking은 번호·이메일 형태만 가리는 보조 장치다.
  class PublicCase
    RESULT_LABELS = {
      "approved" => "인정",
      "rejected" => "불인정",
      "partially_approved" => "일부인정",
      "revised_approved" => "변경인정"
    }.freeze
    JOB_SUMMARY_LENGTH = 200
    REASONING_SUMMARY_LENGTH = 300

    attr_reader :case_no, :disease_name, :result, :year, :decided_on, :job_name,
      :tenure_months, :burden_body_part, :job_summary, :reasoning_summary, :detail_url

    def initialize(record, base_url:)
      @case_no = record.case_no
      @disease_name = record.disease_name
      @result = record.result
      @year = record.year
      @decided_on = record.decided_on
      @job_name = record.job_name
      @tenure_months = record.job_tenure_months
      @burden_body_part = record.burden_body_part.to_s.split("|").map(&:strip).reject(&:blank?)
      @job_summary = summarize(record.job_description, JOB_SUMMARY_LENGTH)
      @reasoning_summary = summarize(record.main_reasoning, REASONING_SUMMARY_LENGTH)
      @detail_url = "#{base_url.to_s.chomp('/')}/disease_cases/#{ERB::Util.url_encode(record.case_no)}"
    end

    def result_label
      RESULT_LABELS[result]
    end

    private

    def summarize(text, length)
      return nil if text.blank?

      PIIMasking.mask(text).squish.truncate(length)
    end
  end
end
