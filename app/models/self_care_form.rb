# frozen_string_literal: true

# 산재알아보기(단계형 자가진단). 단계·허용값은 SelfCareForm::Flow, 문서는 docs/self-care-form.md.
module SelfCareForm
  class << self
    # 통계 응답을 구글 폼으로 보내는 기능이 켜져 있는지. 기본 꺼짐이다(동의 문구·보관 기간·삭제 주체가
    # 확정되기 전에는 켜지 않는다). 구글 연동 묶음에서 설정 파일(config/self_care_form.yml)을 읽도록 바뀐다.
    def google_enabled?
      false
    end
  end
end
