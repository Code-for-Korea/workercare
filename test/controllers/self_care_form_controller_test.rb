# frozen_string_literal: true

require "test_helper"

class SelfCareFormControllerTest < ActionDispatch::IntegrationTest
  Flow = SelfCareForm::Flow

  def begin_session
    post self_care_form_agree_path, params: { consent: "1" }
    assert_redirected_to self_care_form_step_path("situation")
  end

  def answer(step, **params)
    post self_care_form_step_path(step), params: params
  end

  # 입력칸마다 연결된 label이 있는지(label[for] 또는 label 안에 있음)
  def assert_every_input_labelled
    css_select("input, select, textarea").each do |input|
      next if %w[hidden submit button].include?(input["type"])

      labelled = input["id"].present? && css_select("label[for='#{input['id']}']").any?
      labelled ||= input.ancestors("label").any?
      assert labelled, "label이 없는 입력: #{input}"
    end
  end

  # ---- 시작과 동의 ----

  test "the start page explains the purpose and asks for the required consent" do
    get self_care_form_start_path

    assert_response :success
    assert_select "title", text: /산재알아보기/
    assert_select "h1[tabindex='-1'][autofocus]", text: "산재알아보기"
    assert_select "input#consent[type=checkbox]"
    assert_select "label[for=consent]", text: /이해했습니다/
    assert_select "button[type=submit]", text: "시작하기"
    assert_select "form form", count: 0
    assert_every_input_labelled
  end

  test "the nav links to the form and to the apply guide on every page" do
    get root_path
    assert_select "nav a[href='#{self_care_form_start_path}']", text: "산재알아보기"
    assert_select "nav a[href='#{apply_guide_path}']"
  end

  test "starting without the consent shows an error summary, an inline error and keeps the user on the start page" do
    post self_care_form_agree_path

    assert_response :unprocessable_entity
    assert_select ".error-summary[role=alert] a[href='#consent']", text: /오류: 시작하려면/
    assert_select "input#consent[aria-invalid=true][aria-describedby='consent-error']"
    assert_select "#consent-error", text: /오류: 시작하려면/
  end

  test "starting with the consent goes to the first question" do
    begin_session
    follow_redirect!
    assert_response :success
    assert_select "h1", text: "어떤 상황이세요?"
  end

  test "a lost session explains what happened instead of silently going back to the start" do
    [ [ :get, self_care_form_step_path("job") ], [ :get, self_care_form_review_path ], [ :get, self_care_form_result_path ],
      [ :post, self_care_form_step_path("job") ] ].each do |verb, path|
      send(verb, path)
      assert_response :success
      assert_select ".notice[role=status]", text: /진행하던 내용이 사라졌습니다/
      assert_select "button[type=submit]", text: "시작하기"
    end
  end

  # ---- 질문 화면 ----

  test "every question page has a unique title with its number, one h1 focused on load, and labelled inputs" do
    begin_session
    titles = Flow::STEP_KEYS.map do |step|
      get self_care_form_step_path(step)
      assert_response :success

      assert_select "h1", count: 1
      assert_select "h1[tabindex='-1'][autofocus]"
      assert_select "progress[aria-label]"
      assert_select "p.progress-text", text: "질문 5개 중 #{Flow.question_number(step)}번째"
      assert_select "main#main", count: 1
      assert_every_input_labelled
      assert_select "form form", count: 0
      css_select("title").first.text
    end

    assert_equal titles.uniq.size, titles.size
    assert titles.all? { |t| t.start_with?("질문 ") && t.end_with?("산재알아보기") }
  end

  test "the situation page offers the three situations and a skip button" do
    begin_session
    get self_care_form_step_path("situation")

    assert_select "button[name=value]", count: 4
    Flow::SITUATIONS.each { |key, label| assert_select "button[name=value][value=#{key}]", text: label }
    assert_select "button[value=skip]"
  end

  test "the body part page has 19 buttons, a none button and a separate free text form" do
    begin_session
    get self_care_form_step_path("body_part")

    assert_select "ul.choices button[name=value]", count: 19 + 1
    assert_select "button[value='손목']"
    assert_select "button[value=none]", text: "해당 없음"
    assert_select "form.free-text input[name=free_text][maxlength='30'][autocomplete=off]"
    assert_select "form.free-text label[for=free_text_body_part]"
    assert_select "form form", count: 0
  end

  test "the body part title follows the prevention situation" do
    begin_session
    answer("situation", value: "prevention")
    get self_care_form_step_path("body_part")
    assert_select "h1", text: "걱정되는 곳이 어디인가요?"
  end

  test "the job page shows the 54 jobs in five headed groups on one screen" do
    begin_session
    get self_care_form_step_path("job")

    assert_select "section h2", count: 5
    assert_select "section ul.choices button[name=value]", count: 54
    assert_select "button[value='택배기사']"
    assert_select "button[value=none]", text: "모르겠어요"
    assert_select "form.free-text input[name=free_text]"
  end

  test "the decision page offers the four rulings, show all, and skip" do
    begin_session
    get self_care_form_step_path("decision")

    %w[approved rejected partially_approved revised_approved all skip].each do |value|
      assert_select "button[name=value][value=#{value}]"
    end
    assert_select "button[value=approved]", text: "인정"
    assert_select "button[value=all]", text: "모두 보기"
  end

  test "the profile page is one page with four labelled radio groups defaulting to no answer" do
    begin_session
    get self_care_form_step_path("profile")

    assert_select "fieldset legend", count: 4
    assert_select "fieldset input[type=radio]", count: 4 + 5 + 4 + 6 + 17
    %w[respondent application_experience age_band region].each do |field|
      assert_select "input[name=#{field}][value=''][checked]", count: 1
    end
    assert_select "button[name=skip_to_review]", text: "건너뛰고 결과 보기"
    assert_every_input_labelled
  end

  # ---- 답하기 ----

  test "choosing stores the answer in the session and moves on; unknown values change nothing" do
    begin_session
    answer("situation", value: "ill")
    assert_redirected_to self_care_form_step_path("body_part")

    answer("situation", value: "ghost")
    assert_redirected_to self_care_form_step_path("body_part")

    get self_care_form_review_path
    assert_select "dd", text: /이미 아픈 곳이 있어요/
  end

  test "the profile post takes all four answers and anything invalid becomes no answer; skipping goes to the review" do
    begin_session
    answer("profile", respondent: "유가족", application_experience: "불승인을 받음", age_band: "10대", region: "서울")
    assert_redirected_to self_care_form_review_path
    follow_redirect!
    assert_select "dd", text: /유가족/
    assert_select "dd", text: /불승인을 받음/

    answer("profile", respondent: "본인", age_band: "200대")
    follow_redirect!
    assert_select "dd", text: /본인/
    assert_select "dd", text: /답하지 않음/, minimum: 3

    answer("profile", skip_to_review: "1")
    assert_redirected_to self_care_form_review_path
  end

  test "an unknown step is not routed" do
    %w[gender employment_type work_type region_detail ksco respondent].each do |step|
      assert_raises(ActionController::RoutingError, step) { Rails.application.routes.recognize_path("/self-care-form/#{step}") }
      assert_raises(ActionController::RoutingError, step) { Rails.application.routes.recognize_path("/self-care-form/#{step}", method: :post) }
    end

    get "/self-care-form/gender"
    assert_response :not_found
  end

  test "static paths are not captured by the step route" do
    assert_recognizes({ controller: "self_care_form", action: "review" }, "/self-care-form/review")
    assert_recognizes({ controller: "self_care_form", action: "result" }, "/self-care-form/result")
    assert_recognizes({ controller: "self_care_form", action: "reset" }, { method: :post, path: "/self-care-form/reset" })
    assert_recognizes({ controller: "self_care_form", action: "show", step: "situation" }, "/self-care-form/situation")
    assert_recognizes({ controller: "self_care_form", action: "update", step: "profile" }, { method: :post, path: "/self-care-form/profile" })
  end

  # ---- 확인과 다시 시작 ----

  test "the review page lists every choice with a change link that names the item" do
    begin_session
    answer("situation", value: "no_time")
    answer("body_part", free_text: "왼쪽 손목")
    answer("job", value: "택배기사")
    answer("decision", value: "rejected")
    get self_care_form_review_path

    assert_select "h1", text: "고른 내용을 확인하세요"
    assert_select "dd", text: /직접 입력: 왼쪽 손목/
    assert_select "dd", text: /택배기사/
    assert_select "dd", text: /불인정/
    assert_select "dd a[aria-label='신체 부위 바꾸기'][href='#{self_care_form_step_path('body_part')}']"
    assert_select "a[role=button][href='#{self_care_form_result_path}']", text: "결과 보기"
  end

  test "starting over clears the answers and the consent but is a POST" do
    begin_session
    answer("situation", value: "ill")
    post self_care_form_reset_path
    assert_redirected_to self_care_form_start_path

    get self_care_form_step_path("situation")
    assert_select ".notice[role=status]", text: /진행하던 내용이 사라졌습니다/
  end

  # ---- 결과 ----

  def make_cases
    @taek_a = DiseaseCase.create!(case_no: "SCF-A", disease_name: "손목터널증후군", job_name: "택배원", burden_body_part: "손목",
      result: "approved", year: 2024, link: "https://jilbyungcase.comwel.or.kr/service/dataView?id=SCF-A",
      applicant_claim: "SECRET-CLAIM-A", main_reasoning: "SECRET-REASONING-A", job_description: "SECRET-JOB-DESC-A")
    @taek_b = DiseaseCase.create!(case_no: "SCF-B", disease_name: "회전근개파열", job_name: "택배원", burden_body_part: "어깨",
      result: "rejected", year: 2023, applicant_claim: "SECRET-CLAIM-B")
    @cook = DiseaseCase.create!(case_no: "SCF-C", disease_name: "수근관증후군", job_name: "조리원", burden_body_part: "손목|우측 손목",
      result: "approved", year: 2022)
  end

  test "the result lists the cases with only the whitelisted fields and the disclaimer" do
    make_cases
    begin_session
    answer("body_part", value: "손목")
    answer("job", value: "택배기사")
    get self_care_form_result_path

    assert_response :success
    assert_select "h1", text: "비슷한 판정 사례(참고용)"
    assert_select "li h2 a[href='#{disease_case_path('SCF-A')}']", text: "손목터널증후군"
    assert_select "li", text: /직업: 택배원/
    assert_select "li", text: /신체 부위: 손목/
    assert_select "li", text: /판정 결과: 인정/
    assert_select "li", text: /2024년/
    assert_select "a[href='https://jilbyungcase.comwel.or.kr/service/dataView?id=SCF-A'][rel='noopener noreferrer'][target=_blank] .visually-hidden", text: /새 창/
    assert_match "1건을 찾았습니다.", response.body
    assert_match "개인의 산재 인정 여부를 예측하거나", response.body
    assert_no_match(/SECRET-CLAIM|SECRET-REASONING|SECRET-JOB-DESC/, response.body, "서술형 요약은 노출하지 않는다")
    assert_no_match(/인정됩니다|인정될 것|가능성이 높/, response.body)
  end

  test "zero results relax the decision then the job, tell the user, and the more-detail link carries only what produced results" do
    make_cases
    begin_session
    answer("body_part", value: "손목")
    answer("job", value: "조리원")
    answer("decision", value: "rejected")
    get self_care_form_result_path

    assert_select ".notice[role=status]", text: /조건을 줄여서 찾았습니다: 판정 결과/
    assert_select "li h2 a", text: "수근관증후군", count: 1

    link = css_select("a").find { |a| a.text.include?("조건 더 자세히 찾기") }
    query = Rack::Utils.parse_nested_query(URI(link["href"]).query)
    assert_equal Chatbot::BodyPartExpansion.tokens_for("손목"), query["burden_body_part"]
    assert_equal Chatbot::JobExpansion.stems_for("조리원"), query["job_name_any"]
    assert_nil query["result"], "완화로 뺀 판정 결과는 넘기지 않는다"
  end

  test "after the job is dropped the more-detail link has no job keywords" do
    make_cases
    begin_session
    answer("body_part", value: "어깨")
    answer("job", value: "조리원")
    get self_care_form_result_path

    assert_select ".notice[role=status]", text: /조건을 줄여서 찾았습니다: 직업/
    link = css_select("a").find { |a| a.text.include?("조건 더 자세히 찾기") }
    assert_no_match(/job_name_any/, link["href"])
    assert_match(/burden_body_part/, link["href"])
  end

  test "typed free text is never carried to the detail search" do
    make_cases
    begin_session
    answer("job", free_text: "택배")
    answer("body_part", free_text: "왼쪽 손목")
    get self_care_form_result_path

    assert_select ".notice[role=status]", text: /‘손목’\(으\)로 찾았습니다/
    link = css_select("a").find { |a| a.text.include?("조건 더 자세히 찾기") }
    assert_no_match(/택배|job_name/, link["href"].to_s)
  end

  test "an unrecognised typed body part searches without it and says so" do
    make_cases
    begin_session
    answer("body_part", free_text: "등산 중 다침")
    get self_care_form_result_path

    assert_select ".notice[role=status]", text: /신체 부위 조건 없이 찾았습니다/
    assert_select "li h2", minimum: 1
  end

  test "no cases found says so without judging approval" do
    begin_session
    answer("body_part", value: "손목")
    get self_care_form_result_path

    assert_match "찾은 사례가 없습니다", response.body
    assert_match "승인 여부에 대한 판단이 아닙니다", response.body
  end

  test "the apply guide button is always there and the appeal link only for a rejected application" do
    make_cases
    begin_session
    get self_care_form_result_path
    assert_select "a[role=button][href='#{apply_guide_path}']", text: "산재 신청 방법 보기"
    assert_select "a[href='#{apply_guide_path(anchor: 'rejection_appeal')}']", count: 0

    answer("profile", application_experience: "불승인을 받음")
    get self_care_form_result_path
    assert_select "a[href='#{apply_guide_path(anchor: 'rejection_appeal')}']", text: /불복 절차/
  end

  test "the no-time situation shows the application steps and required documents first, others do not" do
    begin_session
    answer("situation", value: "no_time")
    get self_care_form_result_path
    assert_select "section.guide-first details#guide-application"
    assert_select "section.guide-first details#guide-required_documents"

    answer("situation", value: "ill")
    get self_care_form_result_path
    assert_select "section.guide-first", count: 0
  end

  test "the prevention situation titles the result for people doing the same work" do
    begin_session
    answer("situation", value: "prevention")
    get self_care_form_result_path
    assert_select "h1", text: "같은 일을 하는 사람들의 판정 사례(참고용)"
  end

  test "skipping everything still gives the newest cases" do
    make_cases
    begin_session
    get self_care_form_result_path
    assert_select "li h2", minimum: 3
  end

  # ---- 저장하지 않음 ----

  test "the whole flow writes nothing to the database" do
    make_cases
    writes = []
    callback = lambda do |*, payload|
      writes << payload[:sql] if payload[:sql].match?(/\A\s*(INSERT|UPDATE|DELETE|REPLACE)/i)
    end
    ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
      begin_session
      answer("situation", value: "ill")
      answer("body_part", value: "손목")
      answer("job", free_text: "택배")
      answer("decision", value: "approved")
      answer("profile", respondent: "본인", application_experience: "아직 안 함", age_band: "30대", region: "서울")
      get self_care_form_review_path
      get self_care_form_result_path
      post self_care_form_reset_path
    end

    assert_empty writes
  end

  test "typed text and the statistics answers never reach the request log" do
    io = StringIO.new
    previous = ActionController::Base.logger
    ActionController::Base.logger = ActiveSupport::Logger.new(io)
    begin
      begin_session
      answer("body_part", free_text: "비밀입력가나다")
      answer("profile", respondent: "유가족", application_experience: "불승인을 받음", age_band: "60대 이상", region: "충남")
    ensure
      ActionController::Base.logger = previous
    end

    log = io.string
    assert_no_match(/비밀입력가나다/, log)
    assert_no_match(/불승인을 받음|60대 이상|충남/, log)
    assert_match(/\[FILTERED\]/, log)
  end

  test "the session cookie stays far below the 4KB limit even with the longest inputs" do
    begin_session
    answer("situation", value: "no_time")
    answer("body_part", free_text: "가" * 100)
    answer("job", free_text: "나" * 100)
    answer("decision", value: "revised_approved")
    answer("profile", respondent: "피해 노동자의 가족", application_experience: "불승인을 받음", age_band: "60대 이상", region: "충남")

    cookie = response.headers["Set-Cookie"].to_s
    assert_operator cookie.bytesize, :<, 3 * 1024

    get self_care_form_review_path
    assert_select "dd", text: /직접 입력: #{'가' * 30}(?!가)/
    assert_no_match(/#{'가' * 31}/, response.body, "30자를 넘는 입력은 서버가 잘라 저장한다")
  end

  test "answers never appear in the page addresses" do
    begin_session
    answer("body_part", value: "손목")
    answer("profile", respondent: "본인", age_band: "30대", region: "서울")
    follow_redirect!
    assert_no_match(/age_band|region|respondent/, request.fullpath)
    assert_equal self_care_form_review_path, request.path
  end
end
