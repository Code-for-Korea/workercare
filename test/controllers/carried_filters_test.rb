# frozen_string_literal: true

require "test_helper"

# `/`·`/search` 화면에 입력칸이 없는 조건(job_name_any, 체크박스 목록에 없는 신체부위 토큰)을
# 보여 주고 다시 검색해도 유지하는지 확인한다.
class CarriedFiltersTest < ActionDispatch::IntegrationTest
  WRIST_TOKENS = Chatbot::BodyPartExpansion.tokens_for("손목").freeze

  test "nothing is drawn for a normal visit or when the body part is already a checkbox" do
    [ root_path, search_path ].each do |path|
      get path
      assert_select ".carried-filters", count: 0
    end

    # 체크박스 목록(상위 N개)에 있는 토큰만 있으면 화면에 이미 보이므로 안내하지 않는다.
    DiseaseCase.create!(case_no: "TEST-CF-1", burden_body_part: "손목", year: 2024)
    get root_path, params: { burden_body_part: [ "손목" ] }
    assert_select ".carried-filters", count: 0
    assert_select "input[name='burden_body_part[]'][checked]", count: 1
  end

  test "job keywords are shown with a neutral title, kept as hidden fields and removable by a link" do
    [ root_path, search_path ].each do |path|
      get path, params: { job_name_any: %w[택배 배송], year: "2024" }
      assert_response :success

      assert_select ".carried-filters strong", text: "검색 화면에 없는 조건"
      assert_select ".carried-filters li", text: /직종 핵심어: 택배·배송/
      assert_select "form input[type=hidden][name='job_name_any[]']", count: 2
      assert_select "form form", count: 0

      link = css_select(".carried-filters a").find { |a| a.text.include?("직종 조건 빼기") }
      assert link, "직종 조건 빼기 링크"
      assert_no_match(/job_name_any/, link["href"])
      assert_match(/year=2024/, link["href"], "다른 조건은 그대로 둔다")
    end
  end

  test "body part tokens that are not checkboxes are shown by concept name and kept as hidden fields" do
    get root_path, params: { burden_body_part: WRIST_TOKENS }

    assert_select ".carried-filters li", text: /신체 부위: 손목\(좌우 포함\)/
    assert_select "form input[type=hidden][name='burden_body_part[]']", count: WRIST_TOKENS.size
    assert_select "form form", count: 0

    link = css_select(".carried-filters a").find { |a| a.text.include?("신체 부위 조건 빼기") }
    assert_no_match(/burden_body_part/, link["href"], "토큰 전부를 지운 URL")
  end

  test "tokens that match no concept are summarised by count and the removal link clears them all" do
    DiseaseCase.create!(case_no: "TEST-CF-2", burden_body_part: "손목", year: 2024)
    get root_path, params: { burden_body_part: [ "손목", "알 수 없는 부위", "또 다른 부위" ] }

    assert_select ".carried-filters li", text: /신체 부위 토큰 3개/
    # 체크박스에 있는 "손목"은 checked로, 나머지 둘은 hidden으로 남는다.
    assert_select "input[type=checkbox][name='burden_body_part[]'][checked]", count: 1
    assert_select "form input[type=hidden][name='burden_body_part[]']", count: 2

    link = css_select(".carried-filters a").find { |a| a.text.include?("신체 부위 조건 빼기") }
    assert_no_match(/burden_body_part/, link["href"], "일부가 체크박스여도 전부 지운 URL")
  end

  test "resubmitting the search form keeps the carried conditions" do
    get search_path, params: { job_name_any: %w[택배], burden_body_part: WRIST_TOKENS }
    form = css_select("form[action='/search']").first
    hidden = form.css("input[type=hidden]").reject { |i| i["name"] == "authenticity_token" }
    pairs = hidden.map { |i| [ i["name"], i["value"] ] }

    get search_path, params: Rack::Utils.parse_nested_query(pairs.map { |k, v| "#{CGI.escape(k)}=#{CGI.escape(v)}" }.join("&"))
    assert_select ".carried-filters li", text: /직종 핵심어: 택배/
    assert_select "form input[type=hidden][name='job_name_any[]']", count: 1
    assert_select "form input[type=hidden][name='burden_body_part[]']", count: WRIST_TOKENS.size
  end
end
