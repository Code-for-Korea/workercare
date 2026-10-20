# frozen_string_literal: true

require "test_helper"

class Chatbot::JobExpansionTest < ActiveSupport::TestCase
  Expansion = Chatbot::JobExpansion

  test "a dictionary representative expands to its stems" do
    assert_equal %w[조리 주방 급식 음식서비스 음식관련], Expansion.stems_for("조리원")
    assert_equal %w[용접 취부 제관], Expansion.stems_for("용접공")
  end

  test "spaces in the label are ignored" do
    assert_equal Expansion.stems_for("자동차 조립원"), Expansion.stems_for("자동차조립원")
    assert_not_nil Expansion.stems_for(" 자동차  조립원 ")
  end

  test "a word that is not a representative is not expanded" do
    assert_nil Expansion.stems_for("형틀")
    assert_nil Expansion.stems_for("조리")
  end

  test "blank labels are not expanded" do
    [ nil, "", "   " ].each { |label| assert_nil Expansion.stems_for(label) }
  end

  test "every committed concept expands to stems that are searchable" do
    Chatbot::EntityBuilder.load("job_name").concepts.each_key do |name|
      stems = Expansion.stems_for(name)

      assert_not_empty stems, name
      assert stems.all? { |stem| stem.length >= 2 }, "#{name}: 두 글자 미만 핵심어는 후보 검색이 너무 넓어진다"
    end
  end
end
