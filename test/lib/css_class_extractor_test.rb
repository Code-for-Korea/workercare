# frozen_string_literal: true

require "test_helper"
require_relative "../support/css_class_extractor"

class CssClassExtractorTest < ActiveSupport::TestCase
  def classes(css) = CssClassExtractor.classes(css).to_a.sort

  test "comments are ignored" do
    assert_equal %w[b], classes("/* .a { } */ .b { color: red }")
  end

  test "rules inside at-rules are found and the at-rule heads are dropped" do
    css = <<~CSS
      @layer reset, tokens;
      @layer components {
        .a { color: red }
        @media (min-width: 48rem) { .b .c { margin: 0 } }
        @supports (display: grid) { .d { display: grid } }
      }
    CSS
    assert_equal %w[a b c d], classes(css)
  end

  test "classes inside :not() and :is() count" do
    assert_equal %w[a x y], classes(".a:not(.x) { } :is(.y, p) { }")
  end

  test "attribute selectors are not read as classes" do
    assert_equal %w[a], classes('.a[class="a.b"] { } input[value=".c"] { }')
  end

  test "url() and strings in declarations are not read" do
    css = '.a { background: url(a.b.png); content: ".c" } .d::before { content: "\\201C.e" }'
    assert_equal %w[a d], classes(css)
  end

  test "custom property values with decimals are not read" do
    assert_equal %w[a], classes(":root { --x: .5rem } .a { margin: .5rem; --y: calc(.25rem + 1px) }")
  end

  test "comma selectors give every class" do
    assert_equal %w[a b c], classes(".a, .b > .c { }")
  end

  test "an ordinary stylesheet has no forbidden syntax" do
    css = "@layer a, b;\n@layer a { .x { color: red } @media (min-width: 1px) { .y:not(.z) { margin: 0 } } }"
    assert_empty CssClassExtractor.forbidden_syntax(css)
  end

  test "nesting is detected" do
    assert_not_empty CssClassExtractor.forbidden_syntax(".a { color: red; .b { margin: 0 } }")
    assert_not_empty CssClassExtractor.forbidden_syntax(".a { &:hover { margin: 0 } }")
    assert_not_empty CssClassExtractor.forbidden_syntax(".a { &.b { margin: 0 } }")
    assert_not_empty CssClassExtractor.forbidden_syntax(".a { @media (min-width: 1px) { margin: 0 } }")
  end

  test "escaped selectors are detected" do
    assert_not_empty CssClassExtractor.forbidden_syntax('.md\:grid-cols-4 { display: grid }')
  end

  test "@import is detected but a string that mentions it is not" do
    assert_not_empty CssClassExtractor.forbidden_syntax('@import url("a.css");')
    assert_empty CssClassExtractor.forbidden_syntax('.a::before { content: "@import" }')
  end
end
