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

  test "GET /about shows DB-verified overall figures with basis and no per-job approval rates" do
    get about_path
    assert_response :success

    assert_select "h2", text: "알아 두면 좋은 자료"
    assert_select "h3", text: "판정 사례 한눈에 보기"
    assert_select "h3", text: "자주 나오는 질병군·신체 부위"
    assert_select "h3", text: "판정서에 자주 나오는 확인 항목"
    assert_select "main", text: /61,815건.*기준일은 2026-11-11/m
    assert_select "tr", text: /인정\s*30,357건\s*49\.11%/
    assert_select "p", text: /예측|알려 주지 않고/
    assert_select "p", text: /직업이나 질병별 인정 비율도 보여 주지 않습니다/
    assert_select "main", text: /직종별 인정률|직업별 인정률/, count: 0
    assert_select ".table-scroll table", minimum: 3
  end

  test "GET /about says statistics saving is on when the Google Form setting is enabled" do
    SelfCareForm::Settings.current = SelfCareForm::Settings.load(file_fixture("self_care_form_sample.yml"))
    get about_path

    assert_select "h3", text: "통계 저장"
    assert_select "p", text: /구글 폼\(팀의 구글 시트\)에 저장합니다.*IP, 세션 ID는 폼 항목으로 보내지 않습니다.*서버의 IP를 봅니다.*최대 3년/
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

  test "GET /llms.txt declares UTF-8 so Korean text is not garbled" do
    get "/llms.txt"
    assert_response :success
    assert_includes response.headers["Content-Type"], "charset=utf-8"
    assert_includes response.body.dup.force_encoding("UTF-8"), "산재상담실"
  end

  test "GET /robots.txt declares UTF-8" do
    get "/robots.txt"
    assert_response :success
    assert_includes response.headers["Content-Type"], "charset=utf-8"
  end
end
