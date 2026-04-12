# frozen_string_literal: true

require "test_helper"

class SuggestEvidenceToolTest < ActiveSupport::TestCase
  test "returns error/data envelope" do
    result = SuggestEvidenceTool.call(
      user_symptoms: "손목 저림",
      user_work_environment: "사무실",
      disease_category: "musculoskeletal"
    )
    assert result.is_a?(ActionMCP::ToolResponse)

    json = JSON.parse(result.contents.first.text)
    assert json.key?("error")
    assert json.key?("data")
  end

  test "returns missing required evidence for musculoskeletal" do
    result = SuggestEvidenceTool.call(
      user_symptoms: "손목 저림",
      user_work_environment: "사무실",
      current_evidence: [],
      disease_category: "musculoskeletal"
    )
    json = JSON.parse(result.contents.first.text)

    missing = json["data"]["missing_evidence"]
    keys = missing.map { |m| m["type"] }

    assert_includes keys, "객관적 검사 (EMG/NCS, MRI, X-ray)"
    assert_includes keys, "요양급여신청소견서"
  end

  test "filters out evidence user already has" do
    result = SuggestEvidenceTool.call(
      user_symptoms: "손목 저림",
      user_work_environment: "사무실",
      current_evidence: ["정형외과 진단서"],
      disease_category: "musculoskeletal"
    )
    json = JSON.parse(result.contents.first.text)

    missing = json["data"]["missing_evidence"]
    keys = missing.map { |m| m["type"] }

    refute_includes keys, "객관적 검사 (EMG/NCS, MRI, X-ray)"
  end

  test "returns empty recommended_cases when no rejected_case_nos given" do
    result = SuggestEvidenceTool.call(
      user_symptoms: "손목 저림",
      user_work_environment: "사무실",
      disease_category: "musculoskeletal"
    )
    json = JSON.parse(result.contents.first.text)

    assert_empty json["data"]["recommended_cases"]
  end

  test "returns next_steps with immediate hospital visit as first step" do
    result = SuggestEvidenceTool.call(
      user_symptoms: "손목 저림",
      user_work_environment: "사무실",
      disease_category: "musculoskeletal"
    )
    json = JSON.parse(result.contents.first.text)

    steps = json["data"]["next_steps"]
    assert steps.any? { |s| s["action"].include?("산재 지정병원") }
  end

  test "returns legal_basis with labor law references" do
    result = SuggestEvidenceTool.call(
      user_symptoms: "손목 저림",
      user_work_environment: "사무실",
      disease_category: "musculoskeletal"
    )
    json = JSON.parse(result.contents.first.text)

    legal = json["data"]["legal_basis"]
    assert legal.any? { |b| b.include?("산업재해보상보험법") }
  end
end
