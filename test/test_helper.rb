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

# EXAONE 쉬운 요약: 개발자의 .env(dotenv)에 키나 플래그가 있어도 테스트에 새지 않게 비우고, 실제 HTTP 호출은 막는다.
# 호출을 보는 테스트는 `transport`를 직접 끼운다(with_exaone으로 키와 플래그를 켠다).
module OffExaoneByDefault
  FakeExaoneResponse = Struct.new(:code, :body, :headers) do
    def [](name)
      (headers || {})[name.to_s.downcase]
    end
  end

  def before_setup
    super
    @saved_exaone_env = ENV.to_h.slice("EXAONE_API_KEY", "EXAONE_SUMMARY_ENABLED")
    ENV.delete("EXAONE_API_KEY")
    ENV.delete("EXAONE_SUMMARY_ENABLED")
    SelfCareForm::SummaryGenerator.last_request_at = nil
    SelfCareForm::SummaryGenerator.transport = ->(*) { raise "테스트에서 실제 EXAONE을 호출하면 안 됩니다" }
  end

  def after_teardown
    ENV.delete("EXAONE_API_KEY")
    ENV.delete("EXAONE_SUMMARY_ENABLED")
    @saved_exaone_env.each { |key, value| ENV[key] = value }
    SelfCareForm::SummaryGenerator.transport = nil
    super
  end

  def with_exaone(key: "test-key-not-real", enabled: true)
    ENV["EXAONE_API_KEY"] = key
    ENV["EXAONE_SUMMARY_ENABLED"] = "1" if enabled
  end

  # chat.completions 응답을 흉내 낸다. content는 문자열이거나 JSON으로 바꿀 Hash.
  def exaone_response(content, code: 200, headers: nil, finish_reason: "stop")
    content = content.to_json unless content.is_a?(String)
    body = { choices: [ { index: 0, finish_reason: finish_reason, message: { role: "assistant", content: "\n\n#{content}" } } ] }.to_json
    FakeExaoneResponse.new(code.to_s, body, headers)
  end
end
ActiveSupport::TestCase.include OffExaoneByDefault
