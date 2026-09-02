# frozen_string_literal: true

require "test_helper"

class DiseaseCasesControllerTest < ActionDispatch::IntegrationTest
  test "GET / renders the new main search screen" do
    get root_path
    assert_response :success
  end

  test "GET / applies structured filters without a query" do
    get root_path, params: { death_status: "Y" }
    assert_response :success
  end

  test "GET / caps burden_body_part checkboxes and exposes the rest via a datalist" do
    15.times { |i| DiseaseCase.create!(case_no: "TEST-BBP-#{i}", burden_body_part: "부위#{i}", year: 2024) }

    get root_path
    assert_response :success
    assert_select "input[name='burden_body_part[]']", count: DiseaseCasesController::BURDEN_BODY_PART_CHECKBOX_LIMIT
    assert_select "datalist#burden_body_part_datalist option", count: 15
  end

  test "GET / computes burden_body_part token counts only once" do
    3.times { |i| DiseaseCase.create!(case_no: "TEST-BBP-QUERY-#{i}", burden_body_part: "부위#{i}", year: 2024) }

    pluck_count = 0
    subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") do |*, payload|
      pluck_count += 1 if payload[:name] == "DiseaseCase Pluck" && payload[:sql].include?("burden_body_part")
    end

    begin
      get root_path
    ensure
      ActiveSupport::Notifications.unsubscribe(subscriber)
    end

    assert_response :success
    assert_equal 1, pluck_count
  end

  test "GET /search still renders the legacy advanced search screen" do
    get search_path
    assert_response :success
  end

  test "GET /search with query still works (regression)" do
    get search_path, params: { q: "손목" }
    assert_response :success
  end

  test "GET /search also applies the main-screen job_name/death_status filters" do
    DiseaseCase.create!(case_no: "TEST-SEARCH-MAIN-1", disease_name: "매칭케이스",
      job_name: "버스 운전원", death_status: "Y", year: 2024)
    DiseaseCase.create!(case_no: "TEST-SEARCH-MAIN-2", disease_name: "제외케이스",
      job_name: "조립공", death_status: "N", year: 2024)

    get search_path, params: { job_name: "운전", death_status: "Y" }

    assert_response :success
    assert_match "매칭케이스", response.body
    assert_no_match(/제외케이스/, response.body)
  end

  test "GET /search exposes burden_body_part checkbox/datalist options like the main screen" do
    get search_path
    assert_response :success
    assert_select "datalist#burden_body_part_datalist"
  end

  test "GET / and GET /search render employment_type/work_type/work_relevance_eval/ksco_code inputs" do
    [ root_path, search_path ].each do |path|
      get path
      assert_response :success
      assert_select "input[name='employment_type']"
      assert_select "datalist#employment_type_datalist"
      assert_select "input[name='work_type']"
      assert_select "select[name='work_relevance_eval']"
      assert_select "input[name='ksco_code[]']"
      assert_select "datalist#ksco_code_datalist"
    end
  end

  test "GET / filters by employment_type, work_type, work_relevance_eval, and ksco_code" do
    matched = DiseaseCase.create!(case_no: "TEST-STRUCT-MATCH", disease_name: "구조화필터매칭",
      employment_type: "상용직", work_type: "02:30~11:30 (평일 및 토요일)",
      work_relevance_eval: "높음", year: 2024)
    other = DiseaseCase.create!(case_no: "TEST-STRUCT-OTHER", disease_name: "구조화필터제외",
      employment_type: "일용직", work_type: "야간전담", work_relevance_eval: "낮음", year: 2024)
    ksco = KscoCode.create!(code: "TEST-CTRL-8722", name: "버스 운전원")
    DiseaseCaseKscoCode.create!(disease_case: matched, ksco_code: ksco, similarity: 0.9)

    get root_path, params: {
      employment_type: "상용직", work_type: "토요일",
      work_relevance_eval: "높음", ksco_code: [ ksco.code ]
    }

    assert_response :success
    assert_match "구조화필터매칭", response.body
    assert_no_match(/구조화필터제외/, response.body)
  end
end
