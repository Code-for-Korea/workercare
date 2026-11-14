# frozen_string_literal: true

# 단계별 사례 찾기(단계형 자가진단). 단계·허용값은 SelfCareForm::Flow, 문서는 docs/self-care-form.md.
module SelfCareForm
  class << self
    # 통계 응답을 구글 폼으로 보내는 기능이 켜져 있는지. 기본 꺼짐이다(동의 문구·보관 기간·삭제 주체가
    # 확정되기 전에는 켜지 않는다). 설정은 config/self_care_form.yml이고 SelfCareForm::Settings가 검증한다.
    def google_enabled?
      Settings.current.enabled?
    end
  end
end
