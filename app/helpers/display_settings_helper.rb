# 화면 설정 쿠키를 뷰에서 읽는 얇은 래퍼. 규칙은 DisplaySettings에 있다.
module DisplaySettingsHelper
  def display_setting_on?(setting)
    DisplaySettings.new(cookies).on?(setting)
  end

  def display_settings_attributes
    DisplaySettings.new(cookies).html_attributes
  end
end
