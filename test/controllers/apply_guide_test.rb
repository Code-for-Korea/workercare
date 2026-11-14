# frozen_string_literal: true

require "test_helper"

class ApplyGuideControllerTest < ActionDispatch::IntegrationTest
  test "GET /apply-guide shows every topic as an anchored details block with source and date" do
    get apply_guide_path
    assert_response :success

    assert_select "h1", text: "산재 신청 방법 안내"
    assert_select "title", text: /산재 신청 방법 안내 — /
    %w[application required_documents rejection_appeal compensation_types timeline].each do |key|
      assert_select "details##{key}", count: 1
    end
    assert_select "details#rejection_appeal summary h2", text: "불인정 시 대응 절차"
    assert_select "table th[scope=col]"
    assert_match ApplyGuide.last_updated, response.body
    assert_select "a[href^='http'][rel='noopener noreferrer']", count: 0, text: /easylaw/
    assert_select "link[rel=alternate][type='text/markdown'][href='/apply-guide.md']"
  end

  test "GET /apply-guide.md and the Accept header give the markdown with Vary and Link" do
    get "/apply-guide.md"
    assert_response :success
    assert_equal "text/markdown; charset=utf-8", response.headers["Content-Type"]
    assert_includes response.headers["Vary"], "Accept"
    assert_includes response.headers["Link"], 'rel="alternate"; type="text/html"'
    assert_includes response.body, "## 필요 서류"

    get apply_guide_path, headers: { "Accept" => "text/markdown, text/html;q=0.9" }
    assert_equal "text/markdown", response.media_type
    assert_includes response.headers["Vary"], "Accept"
  end

  test "the html version advertises its markdown twin in a Link header" do
    get apply_guide_path
    assert_includes response.headers["Vary"], "Accept"
    assert_includes response.headers["Link"], 'type="text/markdown"'
    assert_includes response.headers["Link"], "/apply-guide.md"
  end

  test "pages without a markdown version do not advertise one" do
    get about_path
    assert_response :success
    refute_match(%r{text/markdown}, response.headers["Link"].to_s, "자산 preload Link는 있어도 마크다운 Link는 없다")
    assert_select "link[rel=alternate][type='text/markdown']", count: 0
  end
end
