# 큰 글씨·고대비 화면 설정을 쿠키로 기억한다. 값은 개인정보가 아니라서 서명하지 않지만 허용값만 읽고 쓴다.
class DisplaySettingsController < ApplicationController
  def update
    DisplaySettings.new(cookies).toggle(params[:setting].to_s)
    redirect_back_or_to root_path
  end
end
