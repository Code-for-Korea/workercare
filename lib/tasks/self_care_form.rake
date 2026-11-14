namespace :self_care_form do
  desc "구글 폼에 만들 문항 목록(앱 키·제목 예·보내는 값·현재 설정 여부)을 출력한다. 문서: docs/self-care-form.md"
  task google_form_spec: :environment do
    puts SelfCareForm::GoogleFormSpec.render(SelfCareForm::Settings.current)
  end

  desc "시험 행 한 줄을 구글 폼으로 보낸다. CONFIRM=1이 필요하고 설정이 올바를 때만 보낸다. 모든 칸이 [테스트]로 시작한다"
  task send_test: :environment do
    settings = SelfCareForm::Settings.current
    unless settings.valid?
      abort "설정이 올바르지 않아 보내지 않습니다(config/self_care_form.yml): #{settings.errors.presence&.join(', ') || 'entries가 비어 있음'}"
    end
    unless ENV["CONFIRM"] == "1"
      abort "연결된 구글 시트에 시험 행이 한 줄 남습니다(모든 칸이 [테스트]로 시작, 시험한 사람이 시트에서 지웁니다). " \
            "그래도 보내려면 CONFIRM=1을 붙여 다시 실행하세요."
    end

    keys = SelfCareForm::Flow::SENDABLE_KEYS & settings.entries.keys
    outcome = SelfCareForm::GoogleFormSubmitter.new(settings: settings).submit(SelfCareForm::GoogleFormSubmitter.test_values(keys))
    puts "보낸 문항: #{keys.join(', ')}"
    puts "결과: sent=#{outcome.sent} status=#{outcome.status.inspect} error=#{outcome.error.inspect}"
    puts "구글은 필수 문항이 빠져도 200을 줍니다. 연결된 시트에서 [테스트] 행이 생겼는지 직접 확인하고 지우세요."
  end
end
