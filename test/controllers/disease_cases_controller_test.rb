# frozen_string_literal: true

require "test_helper"

class DiseaseCasesControllerTest < ActionDispatch::IntegrationTest
  test "GET / renders the new main search screen" do
    get root_path
    assert_response :success
  end

  test "GET / applies structured filters without a query" do
    get root_path, params: { death_status: "Y" }
    assert_response :success
  end

  test "GET / caps burden_body_part checkboxes and exposes the rest via a datalist" do
    15.times { |i| DiseaseCase.create!(case_no: "TEST-BBP-#{i}", burden_body_part: "부위#{i}", year: 2024) }

    get root_path
    assert_response :success
    assert_select "input[name='burden_body_part[]']", count: DiseaseCasesController::BURDEN_BODY_PART_CHECKBOX_LIMIT
    assert_select "datalist#burden_body_part_datalist option", count: 15
  end

  test "GET /search still renders the legacy advanced search screen" do
    get search_path
    assert_response :success
  end

  test "GET /search with query still works (regression)" do
    get search_path, params: { q: "손목" }
    assert_response :success
  end
end
