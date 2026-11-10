# frozen_string_literal: true

require "test_helper"

# 주 메뉴의 aria-current. 값은 항상 "page"이고 헤더 안에 최대 하나다. 표: DESIGN.md
class NavigationTest < ActionDispatch::IntegrationTest
  SITE_NAME = "업무상 질병 판정서"

  def assert_current(link_text)
    assert_select "header [aria-current]", count: 1
    assert_select "header a[aria-current='page']", text: link_text, count: 1
  end

  test "home marks the site name" do
    get root_path
    assert_current SITE_NAME
  end

  test "search marks the search link" do
    get search_path
    assert_current "검색"
  end

  test "apply guide marks its link" do
    get apply_guide_path
    assert_current "산재 신청 방법 안내"
  end

  test "about marks its link" do
    get about_path
    assert_current "소개"
  end

  test "self care form start marks its link" do
    get self_care_form_start_path
    assert_current "단계별 사례 찾기"
  end

  test "a self care form step marks the same link" do
    post self_care_form_agree_path, params: { consent: "1" }
    get self_care_form_step_path("situation")

    assert_response :success
    assert_current "단계별 사례 찾기"
  end

  test "case detail marks nothing" do
    DiseaseCase.create!(case_no: "TEST-NAV-1", disease_name: "상세", year: 2024)
    get disease_case_path("TEST-NAV-1")

    assert_response :success
    assert_select "header [aria-current]", count: 0
  end

  test "aria-current is never true" do
    [ root_path, search_path, apply_guide_path, about_path, self_care_form_start_path ].each do |path|
      get path
      assert_select "[aria-current='true']", count: 0
    end
  end

  test "markdown responses have no aria-current" do
    get "/apply-guide.md"

    assert_response :success
    assert_not_includes response.body, "aria-current"
  end
end
