# frozen_string_literal: true

require "test_helper"

class SelfCareForm::SettingsTest < ActiveSupport::TestCase
  Settings = SelfCareForm::Settings
  SAMPLE_URL = "https://docs.google.com/forms/d/e/1FAIpQLSce45KJEDDH4e2lgtegblriHZDzFL_tQ1UVndkq6Hn7FUmLJA/formResponse"

  def settings(url: SAMPLE_URL, entries: { "body_part" => "123" }, enabled: true)
    Settings.new(enabled: enabled, url: url, entries: entries)
  end

  test "the committed config is off, empty and not an error" do
    committed = Settings.load(Settings::PATH)

    refute committed.enabled?
    refute committed.valid?
    assert_empty committed.errors
    assert_empty committed.entries
    refute SelfCareForm.google_enabled?, "기본은 꺼짐: 시작 화면에 통계용 동의란도 없다"
  end

  test "the sample fixture is valid and enabled with the eight entries" do
    sample = Settings.load(file_fixture("self_care_form_sample.yml"))

    assert sample.enabled?
    assert sample.valid?
    assert_equal 8, sample.entries.size
    assert_equal "1305751224", sample.entries["respondent"]
  end

  test "enabled false keeps a valid config off but valid for send_test" do
    off = settings(enabled: false)
    assert off.valid?
    refute off.enabled?
  end

  test "a url that is not exactly https docs.google.com formResponse is rejected" do
    [ "http://docs.google.com/forms/d/e/ABC/formResponse",
      "https://evil.example/forms/d/e/ABC/formResponse",
      "https://docs.google.com.evil.example/forms/d/e/ABC/formResponse",
      "https://docs.google.com/forms/d/e/ABC/viewform",
      "https://docs.google.com/forms/d/e/ABC/formResponse/extra",
      "https://docs.google.com/forms/d/ABC/formResponse",
      "https://docs.google.com/forms/d/e/ABC/formResponse?usp=pp_url",
      "https://docs.google.com/forms/d/e/ABC/formResponse#x",
      "not a url",
      "" ].each do |url|
      candidate = settings(url: url)
      refute candidate.valid?, "#{url.inspect}는 거부해야 한다"
      refute candidate.enabled?
    end
  end

  test "entries accept only known keys with numeric ids" do
    refute settings(entries: { "body_part" => "abc" }).valid?
    refute settings(entries: { "body_part" => "12 3" }).valid?
    refute settings(entries: { "hacker" => "123" }).valid?, "Flow::SENDABLE_KEYS 밖의 키"
    refute settings(entries: {}).valid?, "entries가 비어 있으면 켜지지 않는다"
    assert settings(entries: { "body_part" => 123, "job" => "456" }).valid?
  end

  test "every entries key must be a sendable key" do
    sample = Settings.load(file_fixture("self_care_form_sample.yml"))
    assert_empty sample.entries.keys - SelfCareForm::Flow::SENDABLE_KEYS
  end

  test "the boot warning appears only when enabled but invalid and never prints values" do
    io = StringIO.new
    logger = Logger.new(io)

    settings(enabled: false, url: "http://bad").warn_if_invalid(logger)
    settings.warn_if_invalid(logger)
    assert_empty io.string, "꺼져 있거나 올바르면 경고하지 않는다"

    settings(url: "http://bad.example/x", entries: { "body_part" => "123" }).warn_if_invalid(logger)
    assert_match(/구글 폼 전송이 꺼졌습니다/, io.string)
    assert_no_match(/bad\.example/, io.string)
  end
end
