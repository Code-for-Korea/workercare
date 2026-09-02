# frozen_string_literal: true

require "test_helper"

class SearchDiseaseCasesToolTest < ActiveSupport::TestCase
  test "returns error/data envelope" do
    result = SearchDiseaseCasesTool.call(q: "손목")
    assert result.is_a?(ActionMCP::ToolResponse)

    json = result.structured_content
    assert json.key?(:error)
    assert json.key?(:data)
  end

  test "returns empty result with zero statistics when no matches" do
    result = SearchDiseaseCasesTool.call(q: "nonexistent_xyz_12345")
    json = result.structured_content

    assert_nil json[:error]
    assert_equal 0, json[:data][:total_count]
    assert_equal 0.0, json[:data][:confidence_score]
    assert_equal true, json[:data][:used_fallback]
    assert_empty json[:data][:cases]
    assert_equal 0, json[:data][:statistics][:total]
  end

  test "limit applies only to cases array not statistics" do
    result = SearchDiseaseCasesTool.call(q: "손목", limit: 1)
    json = result.structured_content

    assert_operator json[:data][:cases].size, :<=, 1
  end

  test "returns strict and substantive approval rates" do
    result = SearchDiseaseCasesTool.call(q: "손목")
    json = result.structured_content

    stats = json[:data][:statistics]
    assert stats.key?(:strict_approval_rate)
    assert stats.key?(:substantive_approval_rate)
    assert stats.key?(:rejection_rate)
  end

  test "q is optional — structured filters alone can be used" do
    disease_case = DiseaseCase.create!(case_no: "TEST-MCP-NO-Q", death_status: "Y",
      job_name: "테스트-MCP-NO-Q-전용직업", year: 2024)

    result = SearchDiseaseCasesTool.call(death_status: "Y", job_name: "테스트-MCP-NO-Q-전용직업")
    json = result.structured_content

    assert_nil json[:error]
    assert_equal 1, json[:data][:total_count]
    assert_includes json[:data][:cases].map { |c| c[:case_no] }, disease_case.case_no
  end

  test "rejects a call with no q and no structured filters instead of returning the whole corpus" do
    result = SearchDiseaseCasesTool.call
    json = result.structured_content

    assert json[:error].present?
    assert_nil json[:data]
  end

  test "date validation returns error for invalid format" do
    result = SearchDiseaseCasesTool.call(q: "손목", decided_on_from: "invalid")
    json = result.structured_content

    assert json[:error].present?
    assert_match(/날짜 형식/, json[:error])
  end

  test "job_name filters results and is reflected in match_reason" do
    disease_case = DiseaseCase.create!(case_no: "TEST-MCP-JOB", job_name: "버스 운전원",
      applicant_claim: "손목 통증 발생", year: 2024)

    result = SearchDiseaseCasesTool.call(q: "손목", job_name: "운전원")
    json = result.structured_content

    assert_nil json[:error]
    matched = json[:data][:cases].find { |c| c[:case_no] == disease_case.case_no }
    assert matched, "job_name으로 필터링된 판정서가 결과에 포함되어야 한다"
    assert_includes matched[:match_reason].map { |r| r[:reason] }, "동일 직종"
  end

  test "death_status filters out non-matching cases" do
    disease_case = DiseaseCase.create!(case_no: "TEST-MCP-DEATH", death_status: "Y",
      applicant_claim: "손목 통증 발생", year: 2024)

    result = SearchDiseaseCasesTool.call(q: "손목", death_status: "N")
    json = result.structured_content

    refute json[:data][:cases].map { |c| c[:case_no] }.include?(disease_case.case_no)
  end

  test "ksco_code filters via disease_case_ksco_codes join" do
    disease_case = DiseaseCase.create!(case_no: "TEST-MCP-KSCO", applicant_claim: "손목 통증 발생", year: 2024)
    ksco = KscoCode.create!(code: "TEST-MCP-9999", name: "테스트 직업")
    DiseaseCaseKscoCode.create!(disease_case: disease_case, ksco_code: ksco, similarity: 1.0)

    result = SearchDiseaseCasesTool.call(q: "손목", ksco_code: [ ksco.code ])
    json = result.structured_content

    assert_includes json[:data][:cases].map { |c| c[:case_no] }, disease_case.case_no
  end
end
