# frozen_string_literal: true

require "test_helper"

class Chatbot::CaseSearchTest < ActiveSupport::TestCase
  def conditions(attrs = {})
    Chatbot::KakaoRequestAdapter::Conditions.new({ ignored: [] }.merge(attrs))
  end

  def search(page: 0, **attrs)
    Chatbot::CaseSearch.new(conditions(attrs), page: page).call
  end

  def create_case(case_no, attrs = {})
    DiseaseCase.create!({ case_no: case_no, disease_name: "회전근개파열", result: "approved", year: 2024 }.merge(attrs))
  end

  test "body part finds the dictionary tokens together with their left/right variants" do
    create_case("CS-1", burden_body_part: "어깨")
    create_case("CS-2", burden_body_part: "우측 견관절|허리")
    create_case("CS-3", burden_body_part: "좌측 어깨")
    create_case("CS-4", burden_body_part: "무릎")
    create_case("CS-5", burden_body_part: nil)

    result = search(body_part: "어깨")

    assert_equal %w[CS-1 CS-2 CS-3], result.cases.map(&:case_no).sort
    assert_equal 3, result.total_count
  end

  test "a body part the dictionary does not know is searched as it is" do
    create_case("CS-6", burden_body_part: "발등")
    create_case("CS-7", burden_body_part: "우측 발등")
    create_case("CS-8", burden_body_part: "어깨")

    assert_equal %w[CS-6 CS-7], search(body_part: "발등").cases.map(&:case_no).sort
  end

  test "body part is combined with the other conditions as AND" do
    create_case("CS-9", disease_name: "회전근개파열", result: "rejected", burden_body_part: "우측 어깨", job_name: "조립원")
    create_case("CS-10", disease_name: "회전근개파열", result: "approved", burden_body_part: "우측 어깨", job_name: "조립원")
    create_case("CS-11", disease_name: "허리디스크", result: "rejected", burden_body_part: "우측 어깨", job_name: "조립원")
    create_case("CS-12", disease_name: "회전근개파열", result: "rejected", burden_body_part: "무릎", job_name: "조립원")

    result = search(disease_name: "회전근개", body_part: "어깨", job_name: "조립", result: "rejected")

    assert_equal [ "CS-9" ], result.cases.map(&:case_no)
  end

  test "no body part leaves the search unfiltered by body part" do
    create_case("CS-13", burden_body_part: "어깨")
    create_case("CS-14", burden_body_part: nil)

    assert_equal %w[CS-13 CS-14], search(disease_name: "회전근개").cases.map(&:case_no).sort
  end

  test "pages through a body part search ten at a time" do
    12.times { |i| create_case("CS-P#{i}", burden_body_part: i.even? ? "어깨" : "우측 어깨", year: 2024 - i) }

    first = search(body_part: "어깨")
    second = search(body_part: "어깨", page: 1)

    assert_equal 10, first.cases.size
    assert first.has_more
    assert_equal 2, second.cases.size
    assert_not second.has_more
  end

  # --- 선택한 직종 이름들(job_names) ---

  test "job_names match whole names ignoring spaces, as an OR" do
    create_case("CS-J1", job_name: "조리원")
    create_case("CS-J2", job_name: "조리 원")
    create_case("CS-J3", job_name: "조리사")
    create_case("CS-J4", job_name: "급식조리원")
    create_case("CS-J5", job_name: "용접공")

    result = search(job_names: [ "조리원", "조리사" ])

    assert_equal %w[CS-J1 CS-J2 CS-J3], result.cases.map(&:case_no).sort
    assert_equal 3, result.total_count
  end

  test "job_names are combined with the other conditions as AND" do
    create_case("CS-J6", job_name: "조리원", disease_name: "손목터널증후군", result: "rejected", burden_body_part: "우측 손목")
    create_case("CS-J7", job_name: "조리사", disease_name: "손목터널증후군", result: "approved", burden_body_part: "손목")
    create_case("CS-J8", job_name: "조리원", disease_name: "허리디스크", result: "rejected", burden_body_part: "허리")

    result = search(job_names: [ "조리원", "조리사" ], disease_name: "손목", body_part: "손목", result: "rejected")

    assert_equal [ "CS-J6" ], result.cases.map(&:case_no)
  end

  test "no job_names leaves the job unfiltered" do
    create_case("CS-J9", job_name: "조리원")
    create_case("CS-J10", job_name: "용접공")

    assert_equal %w[CS-J10 CS-J9], search(disease_name: "회전근개").cases.map(&:case_no).sort
  end
end
