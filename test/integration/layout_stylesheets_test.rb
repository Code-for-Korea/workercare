# frozen_string_literal: true

require "test_helper"

class LayoutStylesheetsTest < ActionDispatch::IntegrationTest
  test "the layout links every design stylesheet and no Pico" do
    get root_path
    hrefs = css_select("link[rel=stylesheet]").map { |l| l["href"].to_s }

    %w[tokens base layout components utilities].each do |name|
      assert hrefs.any? { |h| h.match?(%r{/assets/#{name}-}) }, "missing #{name} stylesheet"
    end
    assert hrefs.none? { |h| h.include?("picocss") }
    assert_equal 1, hrefs.count { |h| h.include?("pretendard@v1.3.9") }
  end
end
