# frozen_string_literal: true

# 같은 주소를 HTML과 마크다운(`.md`·`Accept: text/markdown`)으로 모두 제공하는 컨트롤러가 쓴다.
# 두 표현 모두 `Vary: Accept`와 서로를 가리키는 `Link` 헤더를 달고(헤드리스 fetcher는 <head>를 읽지 않으므로
# 헤더로도 알린다), 레이아웃의 `<link rel="alternate">`에 쓸 `markdown_alternate_path`를 제공한다.
# 문서: docs/markdown-responses.md
#
#   include RepresentationHeaders
#   advertise_markdown only: :apply_guide   # 생략하면 모든 액션
module RepresentationHeaders
  extend ActiveSupport::Concern

  included do
    class_attribute :markdown_actions, instance_writer: false, default: nil
    helper_method :markdown_alternate_path
  end

  class_methods do
    def advertise_markdown(only: nil)
      self.markdown_actions = only && Array(only).map(&:to_s)
      after_action :set_representation_headers, only: only
    end
  end

  private

  def markdown_advertised?
    markdown_actions.nil? || markdown_actions.include?(action_name)
  end

  def markdown_path_base
    path = request.path.sub(/\.md\z/, "")
    path == "/" ? "/index" : path
  end

  # 레이아웃의 <link rel="alternate">용. 마크다운 표현이 없는 액션(about 등)에서는 nil이다.
  def markdown_alternate_path
    return nil unless markdown_advertised?

    suffix = request.query_string.present? ? "?#{request.query_string}" : ""
    "#{markdown_path_base}.md#{suffix}"
  end

  def html_alternate_path
    base = markdown_path_base
    suffix = request.query_string.present? ? "?#{request.query_string}" : ""
    "#{base == '/index' ? '/' : base}#{suffix}"
  end

  def set_representation_headers
    response.headers["Vary"] = [ response.headers["Vary"], "Accept" ].compact_blank.join(", ")
    response.headers["Link"] = if request.format.md?
      "<#{html_alternate_path}>; rel=\"alternate\"; type=\"text/html\""
    else
      "<#{markdown_alternate_path}>; rel=\"alternate\"; type=\"text/markdown\""
    end
  end
end
