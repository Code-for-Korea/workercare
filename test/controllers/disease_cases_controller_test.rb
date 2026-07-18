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

  test "GET /search still renders the legacy advanced search screen" do
    get search_path
    assert_response :success
  end

  test "GET /search with query still works (regression)" do
    get search_path, params: { q: "손목" }
    assert_response :success
  end
end
