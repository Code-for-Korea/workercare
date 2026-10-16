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
    CLAIM_SUMMARY_LENGTH = 200
    # 판정서 원문은 근로복지공단 판정서 사이트에서 본다. 사례마다 저장된 link 컬럼이 같은 형식이며,
    # 비어 있을 때만 사건번호로 이 형식을 조립한다.
    DETAIL_URL_BASE = "https://jilbyungcase.comwel.or.kr/service/dataView?id="

    # 신청인 주장은 글머리표·머리말·주어로 시작하는 경우가 많다. 실제 형태:
    #   "○ 신청인은 ...", "가. 신청인 주장 ○ 신청인은 ...", "<신청인의 주장> - ...",
    #   "- 신청인의 주요 주장은 ...", "1) 신청인 주장 ○ ...", "청구인은 고인이 ..."
    # 목록에서는 글자 수가 매우 적으므로(listCard 제목 30자) 이 상투적인 시작을 걷어 내용부터 보이게 한다.
    # 머리말 뒤에 글머리표가 한 번 더 오는 경우(약 5%)도 걷는다.
    # 글머리 번호는 "1~2자리 숫자 + 공백"일 때만 번호로 본다("2018.5.1.부터"의 날짜를 지우지 않으려고).
    # ○□ 같은 기호는 뒤에 또 마스킹 기호가 이어지면 글머리표가 아니라 비식별 처리된 이름이다("○○○○○에서는").
    CLAIM_BULLET = "(?:[○●ㅇ□■▶◆•·\\-－①-⑩](?![○●ㅇ□■◇◆])\\s*|[가-하]\\.\\s+|\\d{1,2}[.)]\\s+)"
    CLAIM_HEADING = "[<＜\\[]?(?:신청인|청구인|재해자|유족)(?:의)?\\s*(?:주요\\s*)?주장(?:은|는)?[>＞\\]]?\\s*[-:：]?\\s*"
    CLAIM_LEAD = /\A#{CLAIM_BULLET}*(?:#{CLAIM_HEADING}#{CLAIM_BULLET}*)?(?:(?:신청인|청구인)(?:은|는)\s*)?/

    attr_reader :case_no, :disease_name, :result, :year, :decided_on, :job_name,
      :tenure_months, :burden_body_part, :job_summary, :reasoning_summary, :claim_summary, :detail_url

    def initialize(record)
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
      @claim_summary = summarize_claim(record.applicant_claim)
      @detail_url = detail_url_for(record)
    end

    def result_label
      RESULT_LABELS[result]
    end

    private

    def detail_url_for(record)
      return record.link if record.link.to_s.start_with?("https://")

      "#{DETAIL_URL_BASE}#{ERB::Util.url_encode(record.case_no)}"
    end

    def summarize_claim(text)
      return nil if text.blank?

      cleaned = PIIMasking.mask(text).squish.sub(CLAIM_LEAD, "")
      cleaned.presence&.truncate(CLAIM_SUMMARY_LENGTH)
    end

    def summarize(text, length)
      return nil if text.blank?

      PIIMasking.mask(text).squish.truncate(length)
    end
  end
end
