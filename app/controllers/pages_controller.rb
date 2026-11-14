class PagesController < ApplicationController
  include RepresentationHeaders
  advertise_markdown only: :apply_guide

  def about
  end

  # 산재 신청 방법 안내. 화면(/apply-guide)과 마크다운(/apply-guide.md, Accept: text/markdown)이 같은 본문이다.
  def apply_guide
    respond_to do |format|
      format.html
      format.md { render plain: ApplyGuide.markdown, content_type: "text/markdown; charset=utf-8" }
    end
  end
end
