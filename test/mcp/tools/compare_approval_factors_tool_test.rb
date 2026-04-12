# frozen_string_literal: true

require "test_helper"

class CompareApprovalFactorsToolTest < ActiveSupport::TestCase
  test "returns error/data envelope" do
    result = CompareApprovalFactorsTool.call(disease_category: "musculoskeletal")
    assert result.is_a?(ActionMCP::ToolResponse)

    json = JSON.parse(result.contents.first.text)
    assert json.key?("error")
    assert json.key?("data")
  end

  test "extract_status classifies positive correctly" do
    tool = CompareApprovalFactorsTool.new(disease_category: "musculoskeletal")
    rule = {
      keywords: [/근전도/i],
      positive: [/양성/i, /이상 소견/i],
      negative: [/정상/i, /이상 없음/i],
      not_performed: [/미실시/i]
    }

    assert_equal :positive, tool.send(:extract_status, "근전도 검사 양성", rule)
    assert_equal :positive, tool.send(:extract_status, "근전도 이상 소견", rule)
  end

  test "extract_status classifies negative correctly" do
    tool = CompareApprovalFactorsTool.new(disease_category: "musculoskeletal")
    rule = {
      keywords: [/근전도/i],
      positive: [/양성/i],
      negative: [/정상/i, /이상 없음/i],
      not_performed: [/미실시/i]
    }

    assert_equal :negative, tool.send(:extract_status, "근전도 검사 정상", rule)
    assert_equal :negative, tool.send(:extract_status, "근전도 이상 없음", rule)
  end

  test "extract_status classifies not_performed correctly" do
    tool = CompareApprovalFactorsTool.new(disease_category: "musculoskeletal")
    rule = {
      keywords: [/근전도/i],
      positive: [/양성/i],
      negative: [/정상/i],
      not_performed: [/미실시/i, /시행 안함/i]
    }

    assert_equal :not_performed, tool.send(:extract_status, "근전도 미실시", rule)
    assert_equal :not_performed, tool.send(:extract_status, "근전도 검사 시행 안함", rule)
  end

  test "extract_status returns nil when keyword not found" do
    tool = CompareApprovalFactorsTool.new(disease_category: "musculoskeletal")
    rule = { keywords: [/MRI/i], positive: [/양성/i], negative: [/정상/i], not_performed: [/미실시/i] }

    assert_nil tool.send(:extract_status, "근전도 검사 정상", rule)
  end

  test "extract_context returns window around keyword" do
    tool = CompareApprovalFactorsTool.new(disease_category: "musculoskeletal")
    text = "0123456789" * 10
    context = tool.send(:extract_context, text, /567/, window: 5)

    assert_equal "2345678901", context
  end

  test "load_extraction_rules loads from evidence_rules.yml" do
    tool = CompareApprovalFactorsTool.new(disease_category: "musculoskeletal")
    rules = tool.send(:load_extraction_rules)

    assert rules.key?("emg") || rules.key?("mri")
  end
end
