# frozen_string_literal: true

require "test_helper"

# 사이트 전체 레이아웃의 접근성 구조(건너뛰기 링크, 랜드마크). 문서: docs/self-care-form.md
class LayoutAccessibilityTest < ActionDispatch::IntegrationTest
  test "every page starts with a skip link that points to the main landmark" do
    [ root_path, search_path, about_path ].each do |path|
      get path
      assert_response :success

      assert_select "html[lang]"
      first = css_select("body > *").first
      assert_equal "a", first.name
      assert_includes first["class"], "skip-link"
      assert_equal "#main", first["href"]
      assert_select "main#main", count: 1
      assert_select "nav[aria-label='주 메뉴']", count: 1
    end
  end
end
