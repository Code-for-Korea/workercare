# frozen_string_literal: true

require "test_helper"

class SelfCareForm::GoogleFormSpecTest < ActiveSupport::TestCase
  test "the spec lists all ten sendable keys and whether the current config has them" do
    sample = SelfCareForm::Settings.load(file_fixture("self_care_form_sample.yml"))
    table = SelfCareForm::GoogleFormSpec.render(sample)

    assert_equal 10, SelfCareForm::Flow::SENDABLE_KEYS.size
    SelfCareForm::Flow::SENDABLE_KEYS.each { |key| assert_includes table, "`#{key}`" }
    assert_includes table, "있음(447515540)"
    assert_match(/`relaxed`.*없음/, table)
    assert_match(/`result_count`.*없음/, table)
    assert_includes table, "인정 / 불인정 / 일부인정 / 변경인정 / 모두 보기"
  end

  test "the spec with the committed empty config says none of the keys are configured" do
    table = SelfCareForm::GoogleFormSpec.render(SelfCareForm::Settings.load(SelfCareForm::Settings::PATH))
    assert_equal 10, table.scan("| 없음 |").size
  end

  test "every sendable key has a title and a description of its values" do
    SelfCareForm::Flow::SENDABLE_KEYS.each do |key|
      assert SelfCareForm::GoogleFormSpec::TITLES.key?(key), key
      assert SelfCareForm::GoogleFormSpec.values_for(key).present?, key
    end
  end
end
