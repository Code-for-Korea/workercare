# frozen_string_literal: true

require "test_helper"

class SelfCareForm::JobMatcherTest < ActiveSupport::TestCase
  Matcher = SelfCareForm::JobMatcher

  test "exact concept name, colloquial and db surfaces map to the concept" do
    assert_equal "용접공", Matcher.call("용접공").concept
    assert_equal "용접공", Matcher.call("용접사").concept
    assert_equal "용접공", Matcher.call("용접 작업자").concept
    assert_equal "택배기사", Matcher.call("택배").concept
  end

  test "a sentence containing a surface maps to the longest surface's concept" do
    assert_equal "홀서빙", Matcher.call("식당 서빙 일해요").concept
    assert_equal "환경미화원", Matcher.call("청소 일해요").concept
  end

  test "matching is token based: a surface inside a longer word does not match" do
    assert_nil Matcher.call("청소년상담사")
    assert_equal "간호사", Matcher.call("나는 간호사").concept
    assert_equal "용접공", Matcher.call("용접사").concept
    assert_equal "용접공", Matcher.call("용접사예요").concept
  end

  test "no match returns nil" do
    assert_nil Matcher.call("zzqx")
    assert_nil Matcher.call("   ")
    assert_nil Matcher.call(nil)
  end

  test "equal-length surfaces of different concepts are ambiguous and not guessed" do
    dictionary = { "가나" => { db: [], colloquial: [] }, "다라" => { db: [], colloquial: [] } }
    original = Chatbot::EntityDictionary.method(:concepts)
    Chatbot::EntityDictionary.define_singleton_method(:concepts) { |_entity| dictionary }
    begin
      assert_nil Matcher.call("가나다라")
      assert_equal "가나", Matcher.call("가나").concept
    ensure
      Chatbot::EntityDictionary.define_singleton_method(:concepts, original)
    end
  end
end
