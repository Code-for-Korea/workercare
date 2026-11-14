# frozen_string_literal: true

require "test_helper"

class SelfCareForm::BodyPartMatcherTest < ActiveSupport::TestCase
  Matcher = SelfCareForm::BodyPartMatcher

  def concept(text) = Matcher.call(text)&.concept

  test "a multi-character surface is found anywhere in the sentence and the longest one wins" do
    assert_equal "손목", concept("왼쪽 손목")
    assert_equal "발목", concept("발목 통증"), "발·목이 아니라 발목"
    assert_equal "목", concept("경추 디스크"), "db 표기 경추 → 목"
  end

  test "the colloquial spellings of the dictionary are searched too" do
    assert_equal "어깨", concept("어깨 관절이 아파요")
  end

  test "one-character surfaces are accepted only as the whole input or as a word with a particle" do
    assert_equal "눈", concept("눈")
    assert_equal "눈", concept("눈 통증")
    assert_equal "눈", concept("눈이 아파요")
    assert_equal "등", concept("등이 결려요")

    assert_nil concept("등산 중 다침")
    assert_nil concept("눈물이 남")
    assert_nil concept("손님 응대 중")
  end

  test "a longer match beats a one-character match" do
    assert_equal "허리", concept("허리 등이 아파")
  end

  test "surfaces that overlap everyday words follow the strict rule" do
    assert_nil concept("일을 하지 못해요"), "하지(다리)는 동사 활용과 겹친다"
    assert_nil concept("무지 아파요")
    assert_nil concept("수지 가공")
    assert_nil concept("두부 공장")
    assert_equal "다리", concept("하지 통증"), "군더더기를 뗀 입력 전체가 하지"
    assert_equal "다리", concept("하지가 아파요")
  end

  test "known non-body words are removed before matching" do
    assert_nil concept("사다리에서 떨어짐")
    assert_nil concept("전신주 작업 중")
    assert_equal "전신", concept("전신이 아파")
  end

  test "blank input and unknown input return nil" do
    assert_nil concept("")
    assert_nil concept(nil)
    assert_nil concept("아무 말")
  end

  test "equal-length ties go to the concept that comes first in the dictionary" do
    result = Matcher.call("손목")
    assert_equal "손목", result.surface
  end

  test "the strict and non-body constants are in the dictionary or known words" do
    surfaces = Chatbot::EntityDictionary.concepts("body_part").flat_map { |name, body| [ name ] + body[:colloquial] + body[:db] }
                 .map { |s| Chatbot::EntityDictionary.normalize(s) }
    Matcher::STRICT_SURFACES.each { |s| assert_includes surfaces, s, "#{s}는 사전 표기여야 의미가 있다" }
  end
end
