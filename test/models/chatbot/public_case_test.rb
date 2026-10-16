# frozen_string_literal: true

require "test_helper"

class Chatbot::PublicCaseTest < ActiveSupport::TestCase
  test "serializes only the allow-listed fields" do
    record = DiseaseCase.create!(case_no: "TEST-PC-1", disease_name: "회전근개파열", result: "approved", year: 2024,
      job_name: "조립원", job_description: "연락처 010-1234-5678 로 문의. 어깨 반복 작업",
      job_tenure_months: 144, burden_body_part: "어깨|상체", main_reasoning: "판단 이유",
      statement: "진술 원문", medical_records: "진료 기록 원문")

    dto = Chatbot::PublicCase.new(record, base_url: "https://example.test/")

    assert_equal "TEST-PC-1", dto.case_no
    assert_equal "인정", dto.result_label
    assert_equal [ "어깨", "상체" ], dto.burden_body_part
    assert_equal 144, dto.tenure_months
    assert_equal "https://example.test/disease_cases/TEST-PC-1", dto.detail_url
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

    dto = Chatbot::PublicCase.new(record, base_url: "https://example.test")

    assert_operator dto.job_summary.length, :<=, Chatbot::PublicCase::JOB_SUMMARY_LENGTH
    assert_operator dto.reasoning_summary.length, :<=, Chatbot::PublicCase::REASONING_SUMMARY_LENGTH
    assert_equal "https://example.test/disease_cases/TEST%20%ED%95%9C%EA%B8%80%2F1", dto.detail_url
  end
end
