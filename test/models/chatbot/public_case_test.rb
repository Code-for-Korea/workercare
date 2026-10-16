# frozen_string_literal: true

require "test_helper"

class Chatbot::PublicCaseTest < ActiveSupport::TestCase
  test "serializes only the allow-listed fields" do
    record = DiseaseCase.create!(case_no: "TEST-PC-1", disease_name: "회전근개파열", result: "approved", year: 2024,
      job_name: "조립원", job_description: "연락처 010-1234-5678 로 문의. 어깨 반복 작업",
      job_tenure_months: 144, burden_body_part: "어깨|상체", main_reasoning: "판단 이유",
      statement: "진술 원문", medical_records: "진료 기록 원문")

    dto = Chatbot::PublicCase.new(record)

    assert_equal "TEST-PC-1", dto.case_no
    assert_equal "인정", dto.result_label
    assert_equal [ "어깨", "상체" ], dto.burden_body_part
    assert_equal 144, dto.tenure_months
    assert_equal "https://jilbyungcase.comwel.or.kr/service/dataView?id=TEST-PC-1", dto.detail_url
    assert_no_match(/010-1234-5678/, dto.job_summary)
    refute_respond_to dto, :statement
    refute_respond_to dto, :medical_records
  end

  test "result labels cover every enum value" do
    assert_equal DiseaseCase.results.keys.sort, Chatbot::PublicCase::RESULT_LABELS.keys.sort
  end

  test "truncates long text and url-encodes the case_no" do
    record = DiseaseCase.create!(case_no: "TEST 한글/1", disease_name: "x", result: "rejected", year: 2024,
      job_description: "가" * 1000, main_reasoning: "나" * 1000)

    dto = Chatbot::PublicCase.new(record)

    assert_operator dto.job_summary.length, :<=, Chatbot::PublicCase::JOB_SUMMARY_LENGTH
    assert_operator dto.reasoning_summary.length, :<=, Chatbot::PublicCase::REASONING_SUMMARY_LENGTH
    assert_equal "https://jilbyungcase.comwel.or.kr/service/dataView?id=TEST%20%ED%95%9C%EA%B8%80%2F1", dto.detail_url
  end

  test "claim_summary strips leading bullets and the applicant subject, masks numbers and truncates" do
    record = DiseaseCase.create!(case_no: "TEST-PC-CLAIM", disease_name: "x", result: "approved", year: 2024,
      applicant_claim: "○ 신청인 주장 - 신청인은 010-1234-5678 번호로 연락했고 " + "가" * 400)

    dto = Chatbot::PublicCase.new(record)

    assert dto.claim_summary.start_with?("***"), dto.claim_summary
    assert_operator dto.claim_summary.length, :<=, Chatbot::PublicCase::CLAIM_SUMMARY_LENGTH
    assert_no_match(/010-1234-5678/, dto.claim_summary)
  end

  test "claim_summary is nil when the claim is blank or only a lead-in" do
    [ "", nil, "신청인 주장", "○ 신청인은 " ].each do |claim|
      record = DiseaseCase.create!(case_no: "TEST-PC-#{SecureRandom.hex(3)}", disease_name: "x", result: "approved",
        year: 2024, applicant_claim: claim)

      assert_nil Chatbot::PublicCase.new(record).claim_summary, claim.inspect
    end
  end

  test "detail_url prefers the stored Comwel link and falls back to one built from the case number" do
    stored = "https://jilbyungcase.comwel.or.kr/service/dataView?id=740020210001916"
    with_link = DiseaseCase.create!(case_no: "740020210001916", disease_name: "x", result: "approved", year: 2024, link: stored)
    without_link = DiseaseCase.create!(case_no: "240020200002638", disease_name: "x", result: "approved", year: 2024)
    insecure = DiseaseCase.create!(case_no: "240020200002999", disease_name: "x", result: "approved", year: 2024, link: "http://evil.example/x")

    assert_equal stored, Chatbot::PublicCase.new(with_link).detail_url
    assert_equal "https://jilbyungcase.comwel.or.kr/service/dataView?id=240020200002638", Chatbot::PublicCase.new(without_link).detail_url
    assert_equal "https://jilbyungcase.comwel.or.kr/service/dataView?id=240020200002999", Chatbot::PublicCase.new(insecure).detail_url,
      "https가 아닌 저장 링크는 쓰지 않는다"
  end
end
