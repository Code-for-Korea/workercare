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

  test "GET / and GET /search show 원문 as the first result column" do
    DiseaseCase.create!(case_no: "TEST-LINK-COL", link: "https://example.com/case/1", year: 2024)

    [ root_path, search_path ].each do |path|
      get path
      assert_response :success
      headers = css_select("th[scope='col']").map(&:text)
      assert_equal DiseaseCase.human_attribute_name(:link), headers.first
      assert_select "a[href='https://example.com/case/1']"
    end
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

  test "GET /search renders work_type/work_relevance_eval inputs" do
    get search_path
    assert_response :success
    assert_select "input[name='work_type']"
    assert_select "select[name='work_relevance_eval']"
  end

  test "GET / and GET /search never render employment_type or ksco_code inputs — no reason to pick those by hand" do
    [ root_path, search_path ].each do |path|
      get path
      assert_response :success
      assert_select "input[name='employment_type']", count: 0
      assert_select "input[name='ksco_code[]']", count: 0
    end
  end

  test "GET / (simple search) does not render work_type/work_relevance_eval inputs" do
    get root_path
    assert_response :success
    assert_select "input[name='work_type']", count: 0
    assert_select "select[name='work_relevance_eval']", count: 0
  end

  test "GET /search still filters by employment_type and ksco_code via query params (MCP/API-only capability)" do
    matched = DiseaseCase.create!(case_no: "TEST-QS-MATCH", disease_name: "쿼리필터매칭",
      employment_type: "상용직", year: 2024)
    other = DiseaseCase.create!(case_no: "TEST-QS-OTHER", disease_name: "쿼리필터제외",
      employment_type: "일용직", year: 2024)
    ksco = KscoCode.create!(code: "TEST-CTRL-8723", name: "택배 기사")
    DiseaseCaseKscoCode.create!(disease_case: matched, ksco_code: ksco, similarity: 0.9)

    get search_path, params: { employment_type: "상용직", ksco_code: [ ksco.code ] }

    assert_response :success
    assert_match "쿼리필터매칭", response.body
    assert_no_match(/쿼리필터제외/, response.body)
  end

  test "GET / and GET /search show work_type/work_relevance_eval columns in the result list" do
    DiseaseCase.create!(case_no: "TEST-COLS", disease_name: "컬럼표시테스트",
      work_type: "02:30~11:30 (평일 및 토요일)", work_relevance_eval: "매우_높음", year: 2024)

    [ root_path, search_path ].each do |path|
      get path
      assert_response :success
      assert_match "02:30~11:30", response.body
      assert_match "매우 높음", response.body
    end
  end

  test "GET /search filters by work_type and work_relevance_eval" do
    DiseaseCase.create!(case_no: "TEST-STRUCT-MATCH", disease_name: "구조화필터매칭",
      work_type: "02:30~11:30 (평일 및 토요일)", work_relevance_eval: "높음", year: 2024)
    DiseaseCase.create!(case_no: "TEST-STRUCT-OTHER", disease_name: "구조화필터제외",
      work_type: "야간전담", work_relevance_eval: "낮음", year: 2024)

    get search_path, params: { work_type: "토요일", work_relevance_eval: "높음" }

    assert_response :success
    assert_match "구조화필터매칭", response.body
    assert_no_match(/구조화필터제외/, response.body)
  end
end
