# frozen_string_literal: true

require "test_helper"

class SearchDiseaseCasesToolTest < ActiveSupport::TestCase
  test "returns error/data envelope" do
    result = SearchDiseaseCasesTool.call(q: "손목")
    assert result.is_a?(ActionMCP::ToolResponse)

    json = JSON.parse(result.contents.first.text)
    assert json.key?("error")
    assert json.key?("data")
  end

  test "returns empty result with zero statistics when no matches" do
    result = SearchDiseaseCasesTool.call(q: "nonexistent_xyz_12345")
    json = JSON.parse(result.contents.first.text)

    assert_nil json["error"]
    assert_equal 0, json["data"]["total_count"]
    assert_equal 0.0, json["data"]["confidence_score"]
    assert_equal true, json["data"]["used_fallback"]
    assert_empty json["data"]["cases"]
    assert_equal 0, json["data"]["statistics"]["total"]
  end

  test "limit applies only to cases array not statistics" do
    result = SearchDiseaseCasesTool.call(q: "손목", limit: 1)
    json = JSON.parse(result.contents.first.text)

    assert_operator json["data"]["cases"].size, :<=, 1
  end

  test "returns strict and substantive approval rates" do
    result = SearchDiseaseCasesTool.call(q: "손목")
    json = JSON.parse(result.contents.first.text)

    stats = json["data"]["statistics"]
    assert stats.key?("strict_approval_rate")
    assert stats.key?("substantive_approval_rate")
    assert stats.key?("rejection_rate")
  end

  test "date validation returns error for invalid format" do
    result = SearchDiseaseCasesTool.call(q: "손목", decided_on_from: "invalid")
    json = JSON.parse(result.contents.first.text)

    assert json["error"].present?
    assert_match(/날짜 형식/, json["error"])
  end
end
