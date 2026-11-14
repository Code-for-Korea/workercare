# frozen_string_literal: true

require "test_helper"
require_relative "../support/css_class_extractor"

# 렌더된 HTML에 쓰인 class와 스타일시트가 정의한 클래스를 서로 맞춰 본다. 규칙: DESIGN.md "정의만 있는 CSS 클래스를 두지 않는다".
# 허용 목록(test/support/css_class_allowlist.yml)은 이유를 적은 예외뿐이다.
class CssClassesTest < ActionDispatch::IntegrationTest
  STYLESHEET_DIR = Rails.root.join("app/assets/stylesheets")
  # application.css는 사용자 결정으로 그대로 둔 매니페스트 주석뿐이라 검사 대상에서 뺀다(클래스를 정의하지 않는다).
  STYLESHEETS = Dir[STYLESHEET_DIR.join("*.css")].reject { |path| File.basename(path) == "application.css" }.sort.freeze
  ALLOWLIST = YAML.load_file(Rails.root.join("test/support/css_class_allowlist.yml")).freeze

  setup do
    @rendered = Set.new
    seed_cases
  end

  # 13건 이상이어야 Pagy 쪽수 이동(series_nav)이 나온다(한 쪽 12건).
  def seed_cases
    14.times do |i|
      DiseaseCase.create!(case_no: format("CSS-%02d", i), disease_name: "손목터널증후군", job_name: "택배원", burden_body_part: "손목",
        result: i.even? ? "approved" : "rejected", year: 2024 - (i % 3), link: "https://jilbyungcase.comwel.or.kr/service/dataView?id=CSS-#{i}",
        applicant_claim: "청구 #{i}", main_reasoning: "판단 #{i}")
    end
  end

  # 응답 HTML에서 class 토큰을 모은다.
  def collect(status = :success)
    assert_response status, "#{request.fullpath}"
    Nokogiri::HTML(response.body).css("[class]").each { |node| @rendered.merge(node["class"].split) }
  end

  def visit(path, params = {})
    get path, params: params
    collect
  end

  # 통계 전송 동의 화면은 설정이 꺼져 있는 기본값에서는 그려지지 않는다. 샘플 설정으로 켜서 그 클래스도 맞춰 본다.
  def render_stats_states
    SelfCareForm::Settings.current = SelfCareForm::Settings.load(file_fixture("self_care_form_sample.yml"))
    visit self_care_form_start_path
    assert_select "#stats-consent-detail"
    post self_care_form_agree_path, params: { consent: "1", stats_consent: "1" }
    visit self_care_form_review_path
    visit self_care_form_result_path
  ensure
    SelfCareForm::Settings.reset!
  end

  def render_states
    # 메인(`/`)과 상세 검색: 빈 화면, 결과, 필터를 연 상태, 넘어온 조건, 쪽수 이동
    visit root_path
    visit root_path, job_name: "택배원"
    visit root_path, job_name: "택배원", page: 2
    visit root_path, job_name: "없는직업"
    visit root_path, job_name_any: %w[택배 배송], year: "2024"
    visit search_path
    visit search_path, year: "2024"
    visit search_path, year: "2024", page: 2
    visit search_path, job_name_any: %w[택배 배송], burden_body_part: Chatbot::BodyPartExpansion.tokens_for("손목")
    visit disease_case_path("CSS-00")

    # 단계별 사례 찾기: 오류 요약, 질문 5단계, 확인, 결과
    post self_care_form_agree_path
    collect :unprocessable_entity
    visit self_care_form_start_path
    post self_care_form_agree_path, params: { consent: "1" }
    Flow::STEP_KEYS.each { |step| visit self_care_form_step_path(step) }
    post self_care_form_step_path("situation"), params: { value: "no_time" }
    post self_care_form_step_path("body_part"), params: { value: "손목" }
    post self_care_form_step_path("job"), params: { value: "조리원" }
    post self_care_form_step_path("decision"), params: { value: "rejected" }
    post self_care_form_step_path("profile"), params: { application_experience: "불승인을 받음" }
    visit self_care_form_review_path
    visit self_care_form_result_path
    post self_care_form_step_path("body_part"), params: { free_text: "등산 중 다침" }
    visit self_care_form_result_path
    post self_care_form_reset_path
    visit self_care_form_result_path

    # 가이드, 소개, 화면 설정을 켠 상태
    visit apply_guide_path
    visit about_path
    post display_settings_path, params: { setting: "size" }
    post display_settings_path, params: { setting: "contrast" }
    visit root_path

    render_stats_states
  end

  Flow = SelfCareForm::Flow

  test "every rendered class is styled and every styled class is rendered, except the documented exceptions" do
    render_states
    css = STYLESHEETS.flat_map { |path| CssClassExtractor.classes(File.read(path)).to_a }.to_set

    unstyled = ALLOWLIST.fetch("unstyled").keys.to_set
    dynamic = ALLOWLIST.fetch("dynamic").keys.to_set

    missing = (@rendered - css - unstyled).sort
    unused = (css - @rendered - dynamic).sort
    stale = ((unstyled & css) | (dynamic & @rendered)).sort

    assert_empty missing, "화면에 쓰이는데 CSS가 없는 클래스(정의하거나 뷰에서 빼거나 unstyled에 이유와 함께 적는다): #{missing.join(', ')}"
    assert_empty unused, "CSS에 있지만 어떤 화면에도 렌더되지 않는 클래스(지우거나 dynamic에 이유와 함께 적는다): #{unused.join(', ')}"
    assert_empty stale, "허용 목록에 있지만 이제 필요 없는 항목(목록에서 지운다): #{stale.join(', ')}"
  end

  test "the stylesheets use none of the forbidden syntax" do
    STYLESHEETS.each do |path|
      assert_empty CssClassExtractor.forbidden_syntax(File.read(path)), "#{File.basename(path)}에 금지 문법이 있다"
    end
  end

  test "application.css defines no classes" do
    assert_empty CssClassExtractor.classes(File.read(STYLESHEET_DIR.join("application.css")))
  end
end
