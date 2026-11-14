# frozen_string_literal: true

module ApplyGuide
  # 가이드 마크다운을 안전한 HTML로 바꾼다. 저장소 파일이 입력이지만 신뢰하지 않는 입력처럼 다룬다.
  # 기존 DiseaseCases::MarkdownRenderer(DB 본문을 직접 이스케이프하는 출력)와 보안 경계를 분리한 별도 경로다.
  #   ① Redcarpet: 원시 HTML 이스케이프, 안전하지 않은 링크 차단, 이미지·스타일 금지
  #   ② Rails sanitize: 허용 태그·속성 목록 밖은 제거
  #   ③ 링크는 https와 같은 사이트 안(앵커·상대 경로)만 남기고, 표 머리글에 scope를 붙인다
  module HtmlRenderer
    ALLOWED_TAGS = %w[h2 h3 p ul ol li strong em table thead tbody tr th td blockquote br code a].freeze
    ALLOWED_ATTRIBUTES = %w[href rel target].freeze

    RENDERER = Redcarpet::Render::HTML.new(
      escape_html: true, safe_links_only: true, no_images: true, no_styles: true,
      link_attributes: { rel: "noopener noreferrer", target: "_blank" }
    )
    MARKDOWN = Redcarpet::Markdown.new(RENDERER, tables: true, no_intra_emphasis: true)

    class << self
      # @return [ActiveSupport::SafeBuffer]
      def render(markdown)
        html = MARKDOWN.render(markdown.to_s)
        clean = ActionController::Base.helpers.sanitize(html, tags: ALLOWED_TAGS, attributes: ALLOWED_ATTRIBUTES)
        fragment = Nokogiri::HTML5.fragment(clean)
        restrict_links(fragment)
        fragment.css("thead th").each { |th| th["scope"] = "col" }
        fragment.to_html.html_safe
      end

      private

      def restrict_links(fragment)
        fragment.css("a").each do |link|
          href = link["href"].to_s
          next if href.start_with?("https://", "#") || (href.start_with?("/") && !href.start_with?("//"))

          link.replace(link.children) # 링크만 풀고 글자는 남긴다
        end
      end
    end
  end
end
