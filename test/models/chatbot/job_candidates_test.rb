# frozen_string_literal: true

require "test_helper"

class Chatbot::JobCandidatesTest < ActiveSupport::TestCase
  def create_cases(job_name, count)
    count.times { |i| DiseaseCase.create!(case_no: "JC-#{SecureRandom.hex(4)}-#{i}", disease_name: "x", year: 2024, job_name: job_name) }
  end

  def call(*tokens) = Chatbot::JobCandidates.new(tokens).call

  test "candidates are ordered by number of cases, then by name" do
    create_cases("조리원", 3)
    create_cases("조리사", 5)
    create_cases("조리보조", 3)

    assert_equal [ [ "조리사", 5 ], [ "조리보조", 3 ], [ "조리원", 3 ] ], call("조리").map { |c| [ c.name, c.count ] }
  end

  test "names that differ only by spaces are one candidate" do
    create_cases("조리원", 2)
    create_cases("조리 원", 1)
    create_cases("조 리 원", 1)

    result = call("조리")

    assert_equal 1, result.size
    assert_equal 4, result.first.count
  end

  test "matching ignores spaces in the keyword too and matches a part of the name" do
    create_cases("급식 조리원", 2)

    assert_equal [ "급식 조리원" ], call("급식조리").map(&:name)
    assert_equal [ "급식 조리원" ], call("조리 원").map(&:name)
  end

  test "several tokens match any of them" do
    create_cases("조리원", 1)
    create_cases("주방보조", 1)
    create_cases("용접공", 1)

    assert_equal %w[조리원 주방보조], call("조리", "주방").map(&:name).sort
  end

  test "blank and missing job names are never candidates" do
    DiseaseCase.create!(case_no: "JC-NIL", disease_name: "x", year: 2024, job_name: nil)
    DiseaseCase.create!(case_no: "JC-BLANK", disease_name: "x", year: 2024, job_name: "")
    create_cases("조리원", 1)

    assert_equal [ "조리원" ], call("조리").map(&:name)
  end

  test "no tokens or no match returns nothing" do
    create_cases("조리원", 1)

    assert_empty call
    assert_empty call("용접")
  end

  test "the keyword is matched literally, not as a pattern" do
    create_cases("조리원", 1)

    assert_empty call("조%원")
    assert_empty call("조_원")
  end

  test "fetches at most FETCH_LIMIT candidates" do
    (Chatbot::JobCandidates::FETCH_LIMIT + 5).times { |i| create_cases("조리직#{i}", 1) }

    assert_equal Chatbot::JobCandidates::FETCH_LIMIT, call("조리직").size
  end
end
