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

  test "GET /about says statistics saving is on when the Google Form setting is enabled" do
    SelfCareForm::Settings.current = SelfCareForm::Settings.load(file_fixture("self_care_form_sample.yml"))
    get about_path

    assert_select "h3", text: "통계 저장"
    assert_select "p", text: /구글 폼\(팀의 구글 시트\)에 저장합니다.*IP, 세션 ID는 보내지 않습니다.*최대 3년/
    assert_select "p", text: /지금은 꺼져 있어/, count: 0
  ensure
    SelfCareForm::Settings.reset!
  end

  test "GET /about says nothing is sent when the Google Form setting is off" do
    SelfCareForm::Settings.current = SelfCareForm::Settings.new(enabled: false, url: "", entries: {})
    get about_path

    assert_select "p", text: /지금은 꺼져 있어 아무것도 보내지 않습니다/
    assert_select "p", text: /최대 3년/, count: 0
  ensure
    SelfCareForm::Settings.reset!
  end

  test "GET /llms.txt is served and explains the .md addresses" do
    get "/llms.txt"
    assert_response :success
    assert_includes response.body, ".md"
  end
end
