# frozen_string_literal: true

require "test_helper"

class Chatbot::BodyPartExpansionTest < ActiveSupport::TestCase
  Expansion = Chatbot::BodyPartExpansion

  test "expand puts every left/right prefix in front of each token and keeps the bare token" do
    tokens = Expansion.expand([ "어깨" ])

    assert_includes tokens, "어깨"
    assert_includes tokens, "우측 어깨"
    assert_includes tokens, "좌측 어깨"
    assert_includes tokens, "양측 어깨"
    assert_equal [ "어깨", "우측 어깨", "좌측 어깨", "양측 어깨" ], tokens
    assert_equal Expansion::SIDE_PREFIXES.size, tokens.size
  end

  test "expand removes duplicates across tokens" do
    assert_equal Expansion.expand([ "어깨" ]), Expansion.expand([ "어깨", "어깨" ])
  end

  test "tokens_for maps a dictionary representative to its db tokens with side variants" do
    tokens = Expansion.tokens_for("어깨")

    assert_includes tokens, "견관절"
    assert_includes tokens, "우측 견관절"
    assert_includes tokens, "좌측 어깨"
  end

  test "tokens_for ignores spaces in the representative" do
    assert_equal Expansion.tokens_for("어깨"), Expansion.tokens_for(" 어 깨 ")
  end

  test "tokens_for falls back to the label itself with side variants when the dictionary does not know it" do
    tokens = Expansion.tokens_for("발등")

    assert_includes tokens, "발등"
    assert_includes tokens, "우측 발등"
    assert_not_includes tokens, "어깨"
  end

  test "tokens_for returns nothing for a blank label" do
    [ nil, "", "   " ].each { |label| assert_empty Expansion.tokens_for(label) }
  end

  test "the expanded tokens find left/right variants through the real server filter" do
    DiseaseCase.create!(case_no: "BE-1", disease_name: "x", year: 2024, burden_body_part: "어깨")
    DiseaseCase.create!(case_no: "BE-2", disease_name: "x", year: 2024, burden_body_part: "우측 견관절|허리")
    DiseaseCase.create!(case_no: "BE-3", disease_name: "x", year: 2024, burden_body_part: "무릎")

    found = DiseaseCase.apply_main_filters(DiseaseCase.all, burden_body_part: Expansion.tokens_for("어깨")).pluck(:case_no)

    assert_equal %w[BE-1 BE-2], found.sort
  end

  test "every committed concept resolves to tokens" do
    Chatbot::EntityBuilder.load("body_part").concepts.each_key do |name|
      assert_not_empty Expansion.tokens_for(name), name
    end
  end
end
