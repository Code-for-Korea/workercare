# frozen_string_literal: true

require "test_helper"
require "rake"

# lib/tasks/self_care_form.rake: google_form_spec(문항 목록 출력), send_test(CONFIRM=1 필요, 설정이 올바를 때만).
class SelfCareFormTasksTest < ActiveSupport::TestCase
  Response = Struct.new(:code)

  setup do
    Rake.application = Rake::Application.new
    Rake::Task.define_task(:environment)
    load Rails.root.join("lib/tasks/self_care_form.rake")
    @sent = []
    SelfCareForm::GoogleFormSubmitter.transport = lambda do |uri, params|
      @sent << [ uri, params ]
      Response.new("200")
    end
  end

  teardown do
    SelfCareForm::Settings.reset!
    SelfCareForm::GoogleFormSubmitter.transport = nil
    ENV.delete("CONFIRM")
  end

  def capture
    out = StringIO.new
    err = StringIO.new
    old_out, old_err = $stdout, $stderr
    $stdout, $stderr = out, err
    begin
      yield
    ensure
      $stdout, $stderr = old_out, old_err
    end
    [ out.string, err.string ]
  end

  test "google_form_spec prints the ten sendable keys with the current configuration" do
    SelfCareForm::Settings.current = SelfCareForm::Settings.load(file_fixture("self_care_form_sample.yml"))
    out, = capture { Rake::Task["self_care_form:google_form_spec"].invoke }

    SelfCareForm::Flow::SENDABLE_KEYS.each { |key| assert_includes out, "`#{key}`" }
    assert_includes out, "있음(447515540)"
  end

  test "send_test refuses to send with an invalid or empty config" do
    SelfCareForm::Settings.current = SelfCareForm::Settings.new(enabled: true, url: "http://bad", entries: {})
    ENV["CONFIRM"] = "1"

    _, err = capture { assert_raises(SystemExit) { Rake::Task["self_care_form:send_test"].invoke } }
    assert_match(/설정이 올바르지 않아 보내지 않습니다/, err)
    assert_empty @sent
  end

  test "send_test refuses without CONFIRM=1 and explains that a test row stays in the sheet" do
    SelfCareForm::Settings.current = SelfCareForm::Settings.load(file_fixture("self_care_form_sample.yml"))

    _, err = capture { assert_raises(SystemExit) { Rake::Task["self_care_form:send_test"].invoke } }
    assert_match(/CONFIRM=1/, err)
    assert_match(/시험 행이 한 줄 남습니다/, err)
    assert_empty @sent
  end

  test "send_test with CONFIRM=1 sends one row whose every cell starts with the test marker, even while the feature is off" do
    off = SelfCareForm::Settings.new(enabled: false, url: SelfCareForm::Settings.load(file_fixture("self_care_form_sample.yml")).url,
      entries: { "body_part" => "447515540", "job" => "574759984" })
    SelfCareForm::Settings.current = off
    ENV["CONFIRM"] = "1"

    out, = capture { Rake::Task["self_care_form:send_test"].invoke }

    assert_equal 1, @sent.size
    params = @sent.first.last
    assert_equal %w[entry.447515540 entry.574759984], params.keys
    assert params.values.all? { |v| v.start_with?("[테스트]") }
    assert_includes out, "sent=true"
    assert_includes out, "직접 확인하고 지우세요"
  end
end
