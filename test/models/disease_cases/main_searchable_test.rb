# frozen_string_literal: true

require "test_helper"

class DiseaseCases::MainSearchableTest < ActiveSupport::TestCase
  setup do
    @neck = DiseaseCase.create!(case_no: "TEST-MAIN-NECK", job_name: "버스 운전원",
      job_description: "시내버스 운행", burden_body_part: "목", death_status: "N",
      application_type: "요양급여", year: 2024)
    @wrist = DiseaseCase.create!(case_no: "TEST-MAIN-WRIST", job_name: "조립공",
      job_description: "부품 조립", burden_body_part: "손목", death_status: "N",
      application_type: "요양급여", year: 2023)
    @death = DiseaseCase.create!(case_no: "TEST-MAIN-DEATH", job_name: "택배기사",
      job_description: "배송 업무", burden_body_part: "허리|목", death_status: "Y",
      application_type: "유족급여", year: 2022)

    @ksco = KscoCode.create!(code: "TEST-8722", name: "버스 운전원")
    DiseaseCaseKscoCode.create!(disease_case: @neck, ksco_code: @ksco, similarity: 0.9)
  end

  test "burden_body_part filter matches token exactly, not as a substring" do
    scope, = DiseaseCase.main_search(burden_body_part: [ "목" ])
    results = scope.where(case_no: [ @neck.case_no, @wrist.case_no, @death.case_no ])

    assert_includes results, @neck
    assert_includes results, @death
    refute_includes results, @wrist
  end

  test "job_name filter does partial match" do
    scope, = DiseaseCase.main_search(job_name: "운전")
    assert_includes scope, @neck
    refute_includes scope, @wrist
  end

  test "death_status filter" do
    scope, = DiseaseCase.main_search(death_status: "Y")
    assert_includes scope, @death
    refute_includes scope, @neck
  end

  test "ksco_code filter joins through disease_case_ksco_codes" do
    scope, = DiseaseCase.main_search(ksco_code: [ @ksco.code ])
    assert_includes scope, @neck
    refute_includes scope, @wrist
  end

  test "structured filters without a query do not force bm25 ordering" do
    scope, fallback = DiseaseCase.main_search(death_status: "N")
    assert_not fallback
    assert_nothing_raised { scope.to_a }
  end

  test "full text search over job_description finds matches via disease_cases_extracted_fts" do
    scope, fallback = DiseaseCase.main_search(q: "배송")
    assert_includes scope, @death
    assert_not fallback
  end
end
