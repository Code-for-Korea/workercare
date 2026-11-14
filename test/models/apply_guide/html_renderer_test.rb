# frozen_string_literal: true

require "test_helper"

class ApplyGuide::HtmlRendererTest < ActiveSupport::TestCase
  def render(markdown) = ApplyGuide::HtmlRenderer.render(markdown)

  test "raw html, scripts and event handlers are escaped or removed" do
    html = render("<script>alert(1)</script>\n\n<img src=x onerror=alert(1)>\n\n<b onclick=\"x()\">굵게</b>")

    refute_match(/<script/i, html)
    refute_match(/<img/i, html)
    refute_match(/onerror|onclick/i, html.gsub(/&lt;.*?&gt;/m, ""), "이스케이프된 글자 밖에는 이벤트 속성이 없다")
  end

  test "markdown images are not rendered" do
    refute_match(/<img/i, render("![그림](https://example.com/a.png)"))
  end

  test "unsafe link schemes lose the link but keep the text" do
    [ "javascript:alert(1)", "data:text/html;base64,AAAA", "vbscript:x", "//evil.example/path", "ftp://x.example" ].each do |href|
      html = render("[눌러 보세요](#{href})")

      refute_match(/href=/, html, "#{href}는 링크가 남으면 안 된다")
      assert_includes html, "눌러 보세요"
    end
  end

  test "https links, anchors and same-site paths stay, with rel and target" do
    html = render("[공식](https://www.easylaw.go.kr/x) [앵커](#timeline) [내부](/apply-guide)")

    assert_includes html, 'href="https://www.easylaw.go.kr/x"'
    assert_includes html, 'href="#timeline"'
    assert_includes html, 'href="/apply-guide"'
    assert_includes html, 'rel="noopener noreferrer"'
  end

  test "http links are not kept" do
    refute_match(/href=/, render("[옛 주소](http://example.com)"))
  end

  test "tables lists and emphasis survive and table headers get scope" do
    html = render("| 서류 | 비고 |\n|---|---|\n| 신청서 | **필수** |\n\n- 하나\n- 둘\n\n> 인용")

    assert_includes html, "<table>"
    assert_includes html, '<th scope="col">서류</th>'
    assert_includes html, "<strong>필수</strong>"
    assert_includes html, "<li>하나</li>"
    assert_includes html, "<blockquote>"
  end

  test "the whole real guide renders without leftover unsafe markup" do
    ApplyGuide.topics.each do |topic|
      html = render(topic.markdown)
      refute_match(/<script|javascript:|onerror=|<img/i, html, topic.key)
      assert html.present?, topic.key
    end
  end
end
