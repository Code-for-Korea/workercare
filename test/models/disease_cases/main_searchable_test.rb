# frozen_string_literal: true

require "test_helper"

class DiseaseCases::MainSearchableTest < ActiveSupport::TestCase
  setup do
    @neck = DiseaseCase.create!(case_no: "TEST-MAIN-NECK", job_name: "버스 운전원",
      job_description: "시내버스 운행", burden_body_part: "목", death_status: "N",
      application_type: "요양급여", employment_type: "상용직",
      work_type: "02:30~11:30 (평일 및 토요일)", work_relevance_eval: "높음", year: 2024)
    @wrist = DiseaseCase.create!(case_no: "TEST-MAIN-WRIST", job_name: "조립공",
      job_description: "부품 조립", burden_body_part: "손목", death_status: "N",
      application_type: "요양급여", employment_type: "일용직",
      work_type: "주간고정근무", work_relevance_eval: "낮음", year: 2023)
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

  test "burden_body_part_text filter matches token exactly, not as a substring" do
    scope, = DiseaseCase.main_search(burden_body_part_text: "목")
    results = scope.where(case_no: [ @neck.case_no, @wrist.case_no, @death.case_no ])

    assert_includes results, @neck
    assert_includes results, @death
    refute_includes results, @wrist
  end

  test "burden_body_part and burden_body_part_text combine as OR" do
    scope, = DiseaseCase.main_search(burden_body_part: [ "손목" ], burden_body_part_text: "허리")
    results = scope.where(case_no: [ @neck.case_no, @wrist.case_no, @death.case_no ])

    assert_includes results, @wrist
    assert_includes results, @death
    refute_includes results, @neck
  end

  test "job_name filter does partial match" do
    scope, = DiseaseCase.main_search(job_name: "운전")
    assert_includes scope, @neck
    refute_includes scope, @wrist
  end

  test "disease_name filter does partial match even though disease_name is not in the FTS columns" do
    cuff = DiseaseCase.create!(case_no: "TEST-MAIN-CUFF", disease_name: "회전근개파열",
      job_name: "자동차 부품 조립원", job_description: "어깨 반복 작업", year: 2024)

    scope, = DiseaseCase.main_search(disease_name: "회전근개")
    assert_includes scope, cuff
    refute_includes scope, @neck
  end

  test "result filter matches each enum value exactly" do
    cases = DiseaseCase.results.keys.index_with do |result|
      DiseaseCase.create!(case_no: "TEST-MAIN-RESULT-#{result}", result: result, year: 2024)
    end

    cases.each do |result, record|
      scope, = DiseaseCase.main_search(result: result)
      assert_equal [ record ], scope.to_a, "result=#{result}"
    end
  end

  test "disease_name, job_name, result and q combine as AND" do
    match = DiseaseCase.create!(case_no: "TEST-COMBO-MATCH", disease_name: "회전근개파열",
      job_name: "자동차 부품 조립원", job_description: "어깨 팔 거상 반복 작업",
      result: "approved", year: 2024)
    wrong_result = DiseaseCase.create!(case_no: "TEST-COMBO-REJECTED", disease_name: "회전근개파열",
      job_name: "자동차 부품 조립원", job_description: "어깨 팔 거상 반복 작업",
      result: "rejected", year: 2024)
    wrong_disease = DiseaseCase.create!(case_no: "TEST-COMBO-DISEASE", disease_name: "허리디스크",
      job_name: "자동차 부품 조립원", job_description: "어깨 팔 거상 반복 작업",
      result: "approved", year: 2024)

    scope, fallback = DiseaseCase.main_search(disease_name: "회전근개", job_name: "조립",
      q: "거상", result: "approved")

    assert_not fallback
    assert_equal [ match ], scope.to_a
    refute_includes scope, wrong_result
    refute_includes scope, wrong_disease
  end

  test "disease_name and result filters are kept when the FTS query falls back to substring search" do
    kept = DiseaseCase.create!(case_no: "TEST-FALLBACK-KEPT", disease_name: "허리디스크",
      job_name: "물류상하차", result: "rejected", year: 2024)
    DiseaseCase.create!(case_no: "TEST-FALLBACK-OTHER", disease_name: "손목터널증후군",
      job_name: "물류상하차", result: "rejected", year: 2024)
    DiseaseCase.create!(case_no: "TEST-FALLBACK-APPROVED", disease_name: "허리디스크",
      job_name: "물류상하차", result: "approved", year: 2024)

    # job_name/job_description 부분 문자열로만 걸리고 FTS 토큰으로는 0건이 되는 검색어
    scope, fallback = DiseaseCase.main_search(q: "류상하", disease_name: "허리", result: "rejected")
    assert fallback, "fixture must exercise the substring fallback path"
    assert_equal [ kept ], scope.to_a
  end

  test "death_status filter" do
    scope, = DiseaseCase.main_search(death_status: "Y")
    assert_includes scope, @death
    refute_includes scope, @neck
  end

  test "employment_type filter matches exactly" do
    scope, = DiseaseCase.main_search(employment_type: "상용직")
    assert_includes scope, @neck
    refute_includes scope, @wrist
  end

  test "work_type filter does partial (LIKE) match, not exact" do
    scope, = DiseaseCase.main_search(work_type: "평일 및 토요일")
    assert_includes scope, @neck
    refute_includes scope, @wrist
  end

  test "work_relevance_eval filter matches exactly" do
    scope, = DiseaseCase.main_search(work_relevance_eval: "낮음")
    assert_includes scope, @wrist
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
