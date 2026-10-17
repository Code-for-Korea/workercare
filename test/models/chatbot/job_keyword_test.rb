# frozen_string_literal: true

require "test_helper"

class Chatbot::JobKeywordTest < ActiveSupport::TestCase
  Keyword = Chatbot::JobKeyword

  test "clean removes punctuation, squeezes spaces and caps the length" do
    assert_equal "조리 용접", Keyword.clean("  조리,   용접!! ")
    assert_equal 30, Keyword.clean("가" * 100).length
    assert_nil Keyword.clean("   ")
    assert_nil Keyword.clean("?!...")
    assert_nil Keyword.clean(nil)
  end

  test "tokens split the keyword and drop one-letter words" do
    assert_equal %w[조리 용접], Keyword.tokens("조리 용접")
    assert_equal %w[조리], Keyword.tokens("조리 일")
    assert_empty Keyword.tokens("원")
  end

  test "tokens drop speech words and sentence endings" do
    assert_equal %w[조리], Keyword.tokens("조리 일 하는데요")
    assert_equal %w[용접], Keyword.tokens("용접 직종 검색해줘")
    assert_equal %w[청소], Keyword.tokens("청소 일해요")
    assert_empty Keyword.tokens("직종 찾아줘")
  end

  test "tokens strip a trailing polite ending but keep the word" do
    assert_equal %w[조리원], Keyword.tokens("조리원이요")
    assert_equal %w[용접공], Keyword.tokens("용접공이에요")
    assert_equal %w[경비원], Keyword.tokens("경비원입니다")
  end

  test "tokens are unique and capped at three" do
    assert_equal %w[조리 용접 청소], Keyword.tokens("조리 조리 용접 청소 경비")
  end

  test "tokens of nothing is empty" do
    assert_empty Keyword.tokens(nil)
    assert_empty Keyword.tokens("")
  end
end
