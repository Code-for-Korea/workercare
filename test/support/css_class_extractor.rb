# frozen_string_literal: true

# 우리 CSS가 쓰는 제한 문법에서 클래스 선택자를 모은다. 새 gem 없이 중괄호 깊이만 따라간다.
# 제한: 중첩 없음, 선택자 이스케이프 없음, @import 없음. 어기면 forbidden_syntax가 알려 준다.
# 규칙은 DESIGN.md "정의만 있는 CSS 클래스를 두지 않는다".
module CssClassExtractor
  CLASS_NAME = /\.([A-Za-z_][\w-]*)/

  module_function

  # 일반 규칙의 선택자에 나온 클래스 이름 집합(at-rule 머리와 선언 블록은 보지 않는다).
  def classes(css)
    selectors(css).flat_map { |selector| selector.gsub(/\[[^\]]*\]/, "").scan(CLASS_NAME).flatten }.to_set
  end

  # 어긴 문법의 설명 목록. 비어 있으면 통과.
  def forbidden_syntax(css)
    violations = []
    clean = strip_strings(strip_comments(css))
    violations << "@import" if clean.match?(/@import\b/)

    walk(clean) do |kind, text|
      case kind
      when :selector
        violations << "선택자의 백슬래시 이스케이프: #{text.strip}" if text.include?("\\")
        violations << "선택자의 & : #{text.strip}" if text.include?("&")
      when :nested
        violations << "중첩된 규칙: #{text.strip}"
      end
    end
    violations
  end

  def strip_comments(css)
    css.gsub(%r{/\*.*?\*/}m, "")
  end

  # 문자열과 url(...)은 안의 점·괄호가 선택자처럼 읽히지 않도록 지운다.
  def strip_strings(css)
    css.gsub(/"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'/m, '""').gsub(/url\([^)]*\)/i, "url()")
  end

  def selectors(css)
    found = []
    walk(strip_strings(strip_comments(css))) { |kind, text| found << text if kind == :selector }
    found
  end

  # 중괄호를 따라가며 [:selector, 머리] / [:nested, 머리]를 내보낸다.
  # at-rule 머리(@layer, @media, @supports)는 버리고, 그 안의 규칙은 같은 수준으로 본다.
  # 일반 규칙 블록 안에서 `{`가 또 열리면 중첩이다.
  def walk(css)
    stack = []
    buffer = +""
    css.each_char do |char|
      case char
      when "{"
        head = buffer.strip
        buffer = +""
        if head.start_with?("@")
          yield :nested, head if stack.include?(:rule)
          stack << :at
        elsif stack.include?(:rule)
          yield :nested, head
          stack << :rule
        else
          yield :selector, head
          stack << :rule
        end
      when "}"
        stack.pop
        buffer = +""
      when ";"
        buffer = +"" # `@layer a, b;`와 선언 끝
      else
        buffer << char
      end
    end
  end
end
