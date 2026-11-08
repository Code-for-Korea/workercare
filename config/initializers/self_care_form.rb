# frozen_string_literal: true

# 구글 폼 전송 설정이 켜져 있는데 검증에 실패하면 부팅 로그로 알린다(전송은 꺼진 채로 동작한다).
Rails.application.config.after_initialize do
  SelfCareForm::Settings.current.warn_if_invalid
end
