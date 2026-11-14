# frozen_string_literal: true

require "test_helper"

# 큰 글씨·고대비 화면 설정 쿠키. 문서: DESIGN.md 5장
class DisplaySettingsTest < ActionDispatch::IntegrationTest
  def toggle(setting, **options)
    post display_settings_path, params: { setting: setting }, **options
  end

  test "size toggles on and off" do
    toggle "size"
    assert_redirected_to root_path
    assert_equal "large", cookies[:display_size]

    get root_path
    assert_select "html[data-size='large']"
    assert_select "button[aria-pressed='true']", text: "큰 글씨"

    toggle "size"
    assert cookies[:display_size].blank?
    get root_path
    assert_select "html[data-size]", count: 0
    assert_select "button[aria-pressed='false']", text: "큰 글씨"
  end

  test "contrast goes high, normal, high and never deletes the cookie" do
    toggle "contrast"
    assert_equal "high", cookies[:display_contrast]
    get root_path
    assert_select "html[data-contrast='high']"
    assert_select "button[aria-pressed='true']", text: "고대비 화면"

    toggle "contrast"
    assert_equal "normal", cookies[:display_contrast]
    get root_path
    assert_select "html[data-contrast='normal']"
    assert_select "button[aria-pressed='false']", text: "고대비 화면"

    toggle "contrast"
    assert_equal "high", cookies[:display_contrast]
  end

  test "no cookie renders no data attributes and unpressed buttons" do
    get root_path

    assert_select "html[data-size]", count: 0
    assert_select "html[data-contrast]", count: 0
    assert_select ".display-settings button[aria-pressed='false']", count: 2
  end

  test "cookie values outside the allowed list are ignored" do
    cookies[:display_size] = "evil"
    cookies[:display_contrast] = "evil"
    get root_path

    assert_select "html[data-size]", count: 0
    assert_select "html[data-contrast]", count: 0
    assert_select ".display-settings button[aria-pressed='true']", count: 0
  end

  test "an unknown setting changes nothing" do
    toggle "size"
    toggle "evil"
    toggle ""

    assert_response :redirect
    assert_equal "large", cookies[:display_size]
    assert_nil cookies[:display_contrast]
  end

  test "the cookie is long lived, lax and http only" do
    toggle "size"
    header = response.headers["Set-Cookie"]

    assert_match(/display_size=large/, header)
    assert_match(/httponly/i, header)
    assert_match(/samesite=lax/i, header)
    assert_match(/expires=/i, header)
  end

  test "it returns to the same site referer" do
    toggle "size", headers: { "Referer" => "http://www.example.com/search?q=a" }
    assert_redirected_to "http://www.example.com/search?q=a"
  end

  test "an external referer falls back to the root" do
    toggle "size", headers: { "Referer" => "https://evil.example/phish" }
    assert_redirected_to root_path
  end

  test "the header forms are plain forms with turbo disabled" do
    get root_path

    assert_select ".display-settings[role='group'][aria-label='화면 설정']" do
      assert_select "form[action='#{display_settings_path}'][method='post'][data-turbo='false']", count: 2
      assert_select "input[name='setting'][type='hidden']", count: 2
    end
  end
end
