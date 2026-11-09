# frozen_string_literal: true

require "test_helper"

class PagesTest < ActionDispatch::IntegrationTest
  test "GET /about shows the title and the key sections" do
    get about_path
    assert_response :success

    assert_select "title", text: /소개 — /
    assert_select "h1", text: "소개"
    [ "할 수 있는 것", "참고용입니다", "데이터 출처", "개인정보" ].each do |heading|
      assert_select "h2", text: heading
    end
    assert_select "main a[href='#{self_care_form_start_path}']"
    assert_select "main a[href='#{apply_guide_path}']"
    assert_select "main a[href='/llms.txt']"
  end

  test "GET /llms.txt is served and explains the .md addresses" do
    get "/llms.txt"
    assert_response :success
    assert_includes response.body, ".md"
  end
end
