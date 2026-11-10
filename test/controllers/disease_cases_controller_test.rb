# frozen_string_literal: true

require "test_helper"

class DiseaseCasesControllerTest < ActionDispatch::IntegrationTest
  test "GET / renders the new main search screen" do
    get root_path
    assert_response :success
  end

  test "GET / and GET /search render the loading overlay hidden from assistive tech" do
    [ root_path, search_path ].each do |path|
      get path
      assert_select ".loading-overlay[aria-hidden='true'] p.loading-text[role='status']"
    end
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

  test "GET / and GET /search render the same normalized structured filters" do
    [ root_path, search_path ].each do |path|
      get path
      assert_response :success
      assert_select "input[name='application_type[]'][value='요양급여']"
      assert_select "input[name='application_type[]'][value='기타']"
      assert_select "select[name='employment_type'] option", text: "정규직"
      assert_select "select[name='employment_type'] option", text: "기타"
      assert_select "select[name='work_type'] option", text: "고정주간근무"
      assert_select "select[name='work_relevance_eval']"
      assert_select "input[name='death_status']"
    end
  end

  test "GET / and GET /search never render ksco_code inputs — no reason to pick those by hand" do
    [ root_path, search_path ].each do |path|
      get path
      assert_response :success
      assert_select "input[name='ksco_code[]']", count: 0
    end
  end

  test "GET /search uses Korean labels for the decision date range and starts with no checkbox pre-checked" do
    get search_path
    assert_response :success
    assert_select "label[for='decided_on_from']", text: "판정일 (시작)"
    assert_select "label[for='decided_on_to']", text: "판정일 (종료)"
    assert_select "input[name='disease_category[]'][checked]", count: 0
    assert_select "input[name='body_part[]'][checked]", count: 0
  end

  test "GET / filters by several application_type checkboxes with OR" do
    DiseaseCase.create!(case_no: "TEST-APP-1", disease_name: "신청서요양", application_type: "요양급여", year: 2024)
    DiseaseCase.create!(case_no: "TEST-APP-2", disease_name: "신청서유족", application_type: "유족급여|장의비", year: 2024)
    DiseaseCase.create!(case_no: "TEST-APP-3", disease_name: "신청서장해", application_type: "장해급여", year: 2024)

    get root_path, params: { application_type: %w[장의비 요양급여] }

    assert_response :success
    assert_match "신청서요양", response.body
    assert_match "신청서유족", response.body
    assert_no_match(/신청서장해/, response.body)
  end

  test "GET /search still filters by employment_type and ksco_code via query params (URL-only capability)" do
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

  test "GET /disease_cases/:case_no renders an existing case" do
    DiseaseCase.create!(case_no: "TEST-SHOW-OK", disease_name: "상세조회성공", year: 2024)

    get disease_case_path("TEST-SHOW-OK")

    assert_response :success
    assert_match "상세조회성공", response.body
  end

  test "GET / and GET /search put the page title in an h1" do
    [ root_path, search_path ].each do |path|
      get path
      assert_select "h1", count: 1
      assert_select "h3", count: 0
    end
  end

  test "result tables sit in a focusable, labelled scroll region" do
    DiseaseCase.create!(case_no: "TEST-REGION", disease_name: "스크롤영역", year: 2024)

    [ root_path, search_path ].each do |path|
      get path
      assert_select ".table-scroll[role=region][tabindex='0'][aria-label='#{I18n.t('search.results_table')}'] table"
    end
  end

  test "original-document links in both result tables open a new window and say so" do
    DiseaseCase.create!(case_no: "TEST-EXT-ROW", link: "https://example.com/case/ext", year: 2024)

    [ root_path, search_path ].each do |path|
      get path
      assert_select "td a[href='https://example.com/case/ext'][target=_blank][rel='noopener noreferrer']" do
        assert_select "span.sr-only", text: /#{Regexp.escape(I18n.t('search.external_link'))}/
        assert_select "svg[aria-hidden=true][focusable=false]"
      end
    end
  end

  test "the filters details is closed without filter params and open with one" do
    [ root_path, search_path ].each do |path|
      get path
      assert_select "details.filters", count: 1
      assert_select "details.filters[open]", count: 0

      get path, params: { q: "허리", sort: "recent", page: 1, employment_type: "", application_type: [ "" ] }
      assert_select "details.filters[open]", count: 0

      get path, params: { job_name: "택배" }
      assert_select "details.filters[open]", count: 1

      get path, params: { application_type: [ "요양급여" ] }
      assert_select "details.filters[open]", count: 1
    end
  end

  test "GET /disease_cases/:case_no shows the metadata as a dl and an external original link" do
    DiseaseCase.create!(case_no: "TEST-SHOW-EXT", disease_name: "상세외부링크", link: "https://example.com/case/show",
      statement: "긴 원문\n둘째 줄", year: 2024)

    get disease_case_path("TEST-SHOW-EXT")

    assert_select "h1", text: "상세외부링크"
    assert_select "dl.case-meta dt", text: DiseaseCase.human_attribute_name(:case_no)
    assert_select "dd a[href='https://example.com/case/show'][target=_blank][rel='noopener noreferrer'] span.sr-only",
      text: I18n.t("search.external_link")
    assert_select "p.case-text", text: /긴 원문/
  end

  test "GET /disease_cases/:case_no returns 404 for an unknown case_no" do
    get disease_case_path("NO-SUCH-CASE")

    assert_response :not_found
  end

  test "GET /search filters by work_type and work_relevance_eval" do
    DiseaseCase.create!(case_no: "TEST-STRUCT-MATCH", disease_name: "구조화필터매칭",
      work_type: "교대근무", work_type_detail: "4조 3교대", work_relevance_eval: "높음", year: 2024)
    DiseaseCase.create!(case_no: "TEST-STRUCT-OTHER", disease_name: "구조화필터제외",
      work_type: "야간근무", work_relevance_eval: "낮음", year: 2024)

    get search_path, params: { work_type: "교대근무", work_relevance_eval: "높음" }

    assert_response :success
    assert_match "구조화필터매칭", response.body
    assert_no_match(/구조화필터제외/, response.body)
  end

  # --- 마크다운 응답 (.md / Accept: text/markdown) ---

  test "GET /search.md responds with markdown, Vary: Accept and a Link to the HTML twin" do
    DiseaseCase.create!(case_no: "TEST-MD-1", disease_name: "마크다운사례", year: 2024, result: "approved")

    get "/search.md", params: { q: "마크다운사례" }

    assert_response :success
    assert_equal "text/markdown; charset=utf-8", response.headers["Content-Type"]
    assert_includes response.headers["Vary"], "Accept"
    assert_includes response.headers["Link"], 'rel="alternate"; type="text/html"'
    assert_match "[TEST-MD-1](http://www.example.com/disease_cases/TEST-MD-1.md)", response.body
    assert_match "## 검색 방법", response.body
  end

  test "GET / and GET /index.md serve markdown, and the HTML page advertises its markdown twin" do
    DiseaseCase.create!(case_no: "TEST-MD-2", disease_name: "루트마크다운", year: 2024)

    get "/index.md", params: { job_name: "x" }
    assert_response :success
    assert_equal "text/markdown", response.media_type

    get root_path
    assert_response :success
    assert_equal "text/html", response.media_type
    assert_includes response.headers["Vary"], "Accept"
    assert_includes response.headers["Link"], 'type="text/markdown"'
    assert_select "link[rel='alternate'][type='text/markdown'][href='/index.md']"
  end

  test "Accept header negotiation honours q-values in both orders" do
    get root_path, headers: { "Accept" => "text/markdown, text/html;q=0.9" }
    assert_equal "text/markdown", response.media_type

    get root_path, headers: { "Accept" => "text/html, text/markdown;q=0.5" }
    assert_equal "text/html", response.media_type
  end

  test "an unsupported Accept is answered with 406 instead of silently serving HTML" do
    get root_path, headers: { "Accept" => "application/pdf" }
    assert_response :not_acceptable
  end

  test "GET /disease_cases/:case_no.md renders the detail with PII masked" do
    DiseaseCase.create!(case_no: "TEST-MD-3", disease_name: "상세마크다운", year: 2024, result: "approved",
      statement: "연락처 010-1234-5678 입니다", job_name: "버스 운전원")

    get "/disease_cases/TEST-MD-3.md"

    assert_response :success
    assert_equal "text/markdown", response.media_type
    assert_match "# 상세마크다운", response.body
    assert_match "버스 운전원", response.body
    assert_no_match(/010-1234-5678/, response.body)
    assert_match "***", response.body
  end

  test "GET /disease_cases/:case_no.md for an unknown case is 404" do
    get "/disease_cases/NOPE.md"
    assert_response :not_found
  end

  test "markdown search applies the same structured filters as HTML" do
    DiseaseCase.create!(case_no: "TEST-MD-F1", disease_name: "필터요양", application_type: "요양급여", year: 2024)
    DiseaseCase.create!(case_no: "TEST-MD-F2", disease_name: "필터장해", application_type: "장해급여", year: 2024)

    get "/search.md", params: { application_type: [ "요양급여" ] }

    assert_match "필터요양", response.body
    assert_no_match(/필터장해/, response.body)
  end

  test "markdown search lists the allowed values from the code, not a hard-coded copy" do
    get "/search.md"

    %w[요양급여 정규직 고정주간근무].each { |v| assert_match v, response.body }
    assert_match "매우_높음", response.body
  end

  test "job_name_any is accepted by / and /search and by the markdown usage table" do
    DiseaseCase.create!(case_no: "TEST-JANY-1", disease_name: "핵심어매칭", job_name: "택배원", year: 2024)
    DiseaseCase.create!(case_no: "TEST-JANY-2", disease_name: "핵심어제외", job_name: "조리원", year: 2024)

    [ root_path, search_path ].each do |path|
      get path, params: { job_name_any: %w[택배 배송] }
      assert_response :success
      assert_match "핵심어매칭", response.body
      assert_no_match(/핵심어제외/, response.body)
    end

    get "/search.md", params: { job_name_any: %w[택배] }
    assert_match "핵심어매칭", response.body
    assert_match "job_name_any", response.body
  end
end
