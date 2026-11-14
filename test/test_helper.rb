ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# 저장소 설정(config/self_care_form.yml)은 켜져 있다. 그래서 테스트는 기본으로 꺼진 설정에서 시작해, 어떤 테스트도
# 실제 구글로 요청을 보내지 못하게 한다. 켜진 동작을 보는 테스트는 setup에서 설정(과 transport)을 직접 끼운다.
module OffGoogleFormSettingsByDefault
  def before_setup
    super
    SelfCareForm::Settings.current = SelfCareForm::Settings.new(enabled: false, url: "", entries: {})
  end

  def after_teardown
    SelfCareForm::Settings.reset!
    super
  end
end
ActiveSupport::TestCase.include OffGoogleFormSettingsByDefault
