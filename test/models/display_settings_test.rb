# frozen_string_literal: true

require "test_helper"

class DisplaySettingsModelTest < ActiveSupport::TestCase
  # 쿠키 jar 대신 쓰는 해시. DisplaySettings는 [], []=, delete만 쓴다.
  class FakeJar < Hash
    def []=(name, value)
      super(name, value.is_a?(Hash) ? value[:value] : value)
    end
  end

  def settings(**cookies)
    @jar = FakeJar.new.merge!(cookies)
    DisplaySettings.new(@jar)
  end

  test "allowed values are read" do
    s = settings(display_size: "large", display_contrast: "normal")

    assert_equal "large", s.size
    assert_equal "normal", s.contrast
    assert s.large_text?
    assert_not s.high_contrast?
    assert_equal({ data: { "size" => "large", "contrast" => "normal" } }, s.html_attributes)
  end

  test "values outside the allowed list are ignored" do
    s = settings(display_size: "evil", display_contrast: "large")

    assert_nil s.size
    assert_nil s.contrast
    assert_equal({}, s.html_attributes)
  end

  test "no cookie means no attributes and nothing pressed" do
    s = settings

    assert_equal({}, s.html_attributes)
    assert_not s.large_text?
    assert_not s.high_contrast?
  end

  test "size toggles and removes the cookie" do
    s = settings
    s.toggle("size")
    assert_equal "large", @jar[:display_size]

    s.toggle("size")
    assert_not @jar.key?(:display_size)
  end

  test "contrast cycles high and normal and keeps the cookie" do
    s = settings
    s.toggle("contrast")
    assert_equal "high", @jar[:display_contrast]

    s.toggle("contrast")
    assert_equal "normal", @jar[:display_contrast]

    s.toggle("contrast")
    assert_equal "high", @jar[:display_contrast]
  end

  test "unknown settings are ignored" do
    s = settings
    s.toggle("evil")
    s.toggle("")

    assert_empty @jar
    assert_not DisplaySettings.valid?("evil")
  end
end
