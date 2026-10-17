# frozen_string_literal: true

require "test_helper"

class Chatbot::EntityDictionaryTest < ActiveSupport::TestCase
  Dictionary = Chatbot::EntityDictionary

  test "maps each concept to its db variants, keyed without spaces" do
    dictionary = Dictionary.db_by_concept("job_name")

    assert_includes dictionary.keys, "조리원"
    assert_includes dictionary.keys, "자동차조립원", "공백이 있는 대표는 공백 없는 키로 찾는다"
    assert_includes dictionary["조리원"], "조리"
  end

  test "normalize removes every whitespace" do
    assert_equal "자동차조립원", Dictionary.normalize(" 자동차  조립원 ")
    assert_equal "", Dictionary.normalize(nil)
  end

  test "a dictionary file that does not exist is empty" do
    assert_equal({}, Dictionary.db_by_concept("no_such_entity"))
  end

  test "an entity name that could escape the config directory is rejected" do
    assert_raises(ArgumentError) { Dictionary.db_by_concept("../secrets") }
  end

  test "the dictionary is read once and kept until reset" do
    first = Dictionary.db_by_concept("body_part")

    assert_same first, Dictionary.db_by_concept("body_part")
    Dictionary.reset!
    assert_not_same first, Dictionary.db_by_concept("body_part")
    assert_equal first, Dictionary.db_by_concept("body_part")
  end
end
