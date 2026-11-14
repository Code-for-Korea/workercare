# frozen_string_literal: true

require "test_helper"

# tokens.css의 색 토큰 조합이 DESIGN.md 3장의 대비 기준을 넘는지 계산한다(WCAG 2.x 상대 휘도).
# 이름을 바꾸면 DESIGN.md와 이 테스트를 함께 고친다.
class ContrastTest < ActiveSupport::TestCase
  TOKENS_CSS = Rails.root.join("app/assets/stylesheets/tokens.css").read.freeze
  COLOR_TOKENS = %w[bg surface text muted link accent on-accent border focus error].freeze

  # [전경, 배경, 최소 대비]
  PAIRS = [
    %w[text bg 7], %w[text surface 7],
    %w[muted bg 7], %w[muted surface 7],
    %w[link bg 7], %w[link surface 7],
    %w[on-accent accent 7],
    %w[error bg 7], %w[error surface 7],
    %w[focus bg 3], %w[border bg 3]
  ].freeze

  # 선택자로 시작하는 규칙 블록의 본문. 블록 안에 중괄호가 중첩되지 않는 것은 css_classes_test가 보장한다.
  def block_body(selector_pattern)
    match = TOKENS_CSS.match(/#{selector_pattern}\s*\{([^{}]*)\}/m)
    assert match, "tokens.css에서 #{selector_pattern.inspect} 규칙을 찾지 못했다"
    match[1]
  end

  def colors(body)
    COLOR_TOKENS.index_with do |name|
      match = body.match(/--color-#{Regexp.escape(name)}:\s*(#[0-9a-fA-F]{6})\s*;/)
      assert match, "색 토큰 --color-#{name}이 없거나 #rrggbb 형식이 아니다"
      match[1].downcase
    end
  end

  def luminance(hex)
    channels = hex.delete("#").scan(/../).map { |pair| pair.hex / 255.0 }
    r, g, b = channels.map { |c| c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055)**2.4 }
    (0.2126 * r) + (0.7152 * g) + (0.0722 * b)
  end

  def contrast(foreground, background)
    light, dark = [ luminance(foreground), luminance(background) ].sort.reverse
    (light + 0.05) / (dark + 0.05)
  end

  def assert_pairs(theme, palette)
    PAIRS.each do |foreground, background, minimum|
      ratio = contrast(palette.fetch(foreground), palette.fetch(background))
      assert_operator ratio, :>=, minimum.to_f,
        "#{theme}: #{foreground} #{palette[foreground]} / #{background} #{palette[background]} 대비 #{ratio.round(2)}:1 (기준 #{minimum}:1)"
    end
  end

  test "light theme pairs meet the DESIGN.md thresholds" do
    assert_pairs "밝은 화면", colors(block_body(/:root/))
  end

  test "high contrast theme pairs meet the DESIGN.md thresholds" do
    assert_pairs "고대비", colors(block_body(/:root\[data-contrast="high"\]/))
  end

  test "the prefers-contrast block has exactly the same values as the high contrast block" do
    high = colors(block_body(/:root\[data-contrast="high"\]/))
    os = colors(block_body(/:root:not\(\[data-contrast\]\)/))
    assert_equal high, os
  end

  test "the contrast formula matches known values" do
    assert_in_delta 21.0, contrast("#000000", "#ffffff"), 0.001
    assert_in_delta 1.0, contrast("#777777", "#777777"), 0.001
  end
end
