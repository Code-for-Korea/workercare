# frozen_string_literal: true

require "test_helper"

class Webhooks::KakaoJobsControllerTest < ActionDispatch::IntegrationTest
  JOBS = "/webhooks/kakao/jobs"
  CASES = "/webhooks/kakao"

  setup do
    @original_allow_blank_token = Webhooks::KakaoJobsController.allow_blank_token
    @original_token = ENV["KAKAO_SKILL_TOKEN"]
    ENV.delete("KAKAO_SKILL_TOKEN")
    create_cases("조리원", 3, disease_name: "손목터널증후군")
    create_cases("조리사", 2, disease_name: "허리디스크")
    create_cases("용접공", 1, disease_name: "회전근개파열")
  end

  teardown do
    Webhooks::KakaoJobsController.allow_blank_token = @original_allow_blank_token
    ENV["KAKAO_SKILL_TOKEN"] = @original_token
  end

  def create_cases(job_name, count, disease_name: "x")
    count.times { |i| DiseaseCase.create!(case_no: "JK-#{SecureRandom.hex(5)}", disease_name: disease_name, result: "approved", year: 2024 - i, job_name: job_name) }
  end

  def payload(utterance: "x", params: {}, extra: nil, contexts: [])
    { userRequest: { utterance: utterance, user: { id: "bot-user-1" } }, contexts: contexts, action: { params: params, clientExtra: extra } }
  end

  def post_to(path, body, headers: {})
    post path, params: body.to_json, headers: { "CONTENT_TYPE" => "application/json" }.merge(headers)
  end

  def awaiting = [ { name: "job_kw", lifespan: 1 } ]
  def outputs = response.parsed_body.dig("template", "outputs")
  def quick_replies = response.parsed_body.dig("template", "quickReplies")
  def list_items = outputs.filter_map { |o| o["listCard"] }.flat_map { |c| c["items"] }
  def summary = outputs.first.dig("simpleText", "text")

  # --- 검색 ---

  test "a typed keyword is searched while the keyword context is active" do
    post_to JOBS, payload(utterance: "조리 일 하는데요", contexts: awaiting)

    assert_response :success
    assert_equal "2.0", response.parsed_body["version"]
    assert_equal [ "조리원", "조리사" ], list_items.map { |i| i["title"] }
    assert_equal [ "3건", "2건" ], list_items.map { |i| i["description"] }
    assert_includes summary, "'조리'로 찾은 직종 2개 중 1~2번째"
  end

  test "an utterance outside the keyword context is not searched" do
    post_to JOBS, payload(utterance: "조리", contexts: [])

    assert_response :success
    assert_empty list_items
    assert_includes summary, "찾고 싶은 직종을 입력해 주세요"
  end

  test "an explicit keyword parameter is searched without a context" do
    post_to JOBS, payload(params: { keyword: "용접" })

    assert_equal [ "용접공" ], list_items.map { |i| i["title"] }
  end

  test "a keyword that is too short asks again with a note" do
    post_to JOBS, payload(params: { keyword: "원" })

    assert_empty list_items
    assert_includes summary, "두 글자 이상"
  end

  test "an unknown job says so and keeps the user in the keyword step" do
    post_to JOBS, payload(utterance: "없는직종", contexts: awaiting)

    assert_empty list_items
    assert_includes summary, "'없는직종'에 맞는 직종을 찾지 못했어요"
    assert_equal "job_kw", response.parsed_body.dig("context", "values", 0, "name")
  end

  # --- 선택 ---

  test "picking adds to the selection and picking again removes it" do
    post_to JOBS, payload(extra: { keyword: "조리", selected: [], page: 0, pick: "조리원" })

    assert_includes summary, "선택한 직종(1): 조리원"
    assert_equal [ "✓ 조리원", "조리사" ], list_items.map { |i| i["title"] }
    assert_equal({ "job_names" => [ "조리원" ] }, quick_replies.find { |q| q["label"] == "선택한 직종으로 찾기" }["extra"])

    post_to JOBS, payload(extra: { keyword: "조리", selected: [ "조리원" ], page: 0, pick: "조리원" })

    assert_includes summary, "선택한 직종이 아직 없어요"
    assert_nil quick_replies.find { |q| q["label"] == "선택한 직종으로 찾기" }
  end

  test "several jobs can be selected one after another" do
    post_to JOBS, payload(extra: { keyword: "조리", selected: [ "조리원" ], page: 0, pick: "조리사" })

    assert_includes summary, "선택한 직종(2): 조리원, 조리사"
    assert_equal [ "✓ 조리원", "✓ 조리사" ], list_items.map { |i| i["title"] }
  end

  test "paging keeps the selection" do
    30.times { |i| create_cases("조리직#{format('%02d', i)}", 1) }

    post_to JOBS, payload(utterance: "조리직", contexts: awaiting)
    more = quick_replies.find { |q| q["label"] == "직종 더 보기" }
    assert_equal 10, list_items.size
    assert_includes summary, "1~10번째"

    post_to JOBS, payload(extra: more["extra"].merge("selected" => [ "조리직03" ]))

    assert_equal 10, list_items.size
    assert_includes summary, "11~20번째"
    assert_includes summary, "선택한 직종(1): 조리직03"
    assert_equal "직종 더 보기", quick_replies.find { |q| q["label"] == "이전 직종" }["messageText"]
  end

  # --- 선택한 직종으로 판정 사례 찾기 ---

  test "the find button searches the cases of exactly the selected jobs through the case search skill" do
    post_to JOBS, payload(extra: { keyword: "조리", selected: [ "조리원" ], page: 0, pick: "조리사" })
    find = quick_replies.find { |q| q["label"] == "선택한 직종으로 찾기" }

    post_to CASES, payload(extra: find["extra"])

    assert_response :success
    assert_equal 5, response.parsed_body.dig("template", "outputs").last.dig("listCard", "items").size
    assert_includes response.parsed_body.dig("template", "outputs", 0, "simpleText", "text"), "검색 조건: 직종 조리원, 조리사"
    assert_includes response.parsed_body.dig("template", "outputs", 0, "simpleText", "text"), "총 5건"
  end

  test "selected jobs match whole names ignoring spaces, not parts of other names" do
    create_cases("조리 원", 1)
    create_cases("급식조리원", 4)

    post_to CASES, payload(extra: { job_names: [ "조리원" ] })

    items = response.parsed_body.dig("template", "outputs").last.dig("listCard", "items")
    assert_equal 4, items.size, "조리원 3건 + '조리 원' 1건. 급식조리원은 포함되지 않는다"
  end

  # --- 인증·안전 ---

  test "requests need the shared skill token when one is configured" do
    ENV["KAKAO_SKILL_TOKEN"] = "s3cret"

    post_to JOBS, payload(params: { keyword: "조리" })
    assert_response :unauthorized

    post_to JOBS, payload(params: { keyword: "조리" }), headers: { "X-Skill-Token" => "wrong" }
    assert_response :unauthorized

    post_to JOBS, payload(params: { keyword: "조리" }), headers: { "X-Skill-Token" => "s3cret" }
    assert_response :success
    assert_equal 2, list_items.size
  end

  test "fails closed when no token is configured and blank tokens are not allowed" do
    Webhooks::KakaoJobsController.allow_blank_token = false

    post_to JOBS, payload(params: { keyword: "조리" })

    assert_response :unauthorized
  end

  test "malformed JSON still gets a valid skill response" do
    post JOBS, params: "{not json", headers: { "CONTENT_TYPE" => "application/json" }

    assert_response :success
    assert_equal "2.0", response.parsed_body["version"]
    assert_includes summary, "찾고 싶은 직종을 입력해 주세요"
  end

  test "logs counts and timing but never the keyword or the job names" do
    io = StringIO.new
    Rails.logger.broadcast_to(Logger.new(io))

    post_to JOBS, payload(utterance: "비밀스러운검색어조리", contexts: awaiting, extra: nil)
    post_to JOBS, payload(extra: { keyword: "조리", selected: [ "조리원" ], page: 0, pick: "조리사" })

    lines = io.string.lines.select { |line| line.include?("kakao_job_search") }
    assert_equal 2, lines.size
    lines.each { |line| assert_no_match(/조리|비밀스러운검색어|bot-user-1/, line) }
    assert_match(/"keyword_source":"extra"/, lines.last)
    assert_match(/"selected_count":2/, lines.last)
  ensure
    Rails.logger.stop_broadcasting_to(Rails.logger.broadcasts.last) if Rails.logger.respond_to?(:broadcasts) && Rails.logger.broadcasts.size > 1
  end

  test "does not require a CSRF token" do
    original = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true

    post_to JOBS, payload(params: { keyword: "조리" })

    assert_response :success
  ensure
    ActionController::Base.allow_forgery_protection = original
  end

  test "an unexpected error returns a fallback skill response with HTTP 200" do
    Chatbot::JobCandidates.class_eval do
      alias_method :original_call, :call
      define_method(:call) { raise "boom" }
    end

    post_to JOBS, payload(params: { keyword: "조리" })

    assert_response :success
    assert_equal "2.0", response.parsed_body["version"]
    assert_includes summary, "일시적인 문제"
  ensure
    Chatbot::JobCandidates.class_eval do
      alias_method :call, :original_call
      remove_method :original_call
    end
  end

  # --- 엔티티 대표어(카카오가 보내는 값)는 사전의 핵심어로 넓혀 찾는다 ---

  test "an entity representative finds the related jobs, not only names containing it" do
    create_cases("주방보조", 4)
    create_cases("급식실 근무", 1)

    post_to JOBS, payload(params: { keyword: "조리원" })

    titles = list_items.map { |i| i["title"] }
    assert_includes titles, "조리사", "'조리원'이라는 글자가 없어도 사전 핵심어(조리)로 찾는다"
    assert_includes titles, "주방보조"
    assert_includes titles, "급식실 근무"
    assert_not_includes titles, "용접공"
    assert_includes summary, "'조리원'으로 찾은 직종"
  end

  test "the representative itself is carried so later pages expand the same way" do
    10.times { |i| create_cases("조리직#{format('%02d', i)}", 1) }
    create_cases("주방일", 1)

    post_to JOBS, payload(params: { keyword: "조리원" })
    more = quick_replies.find { |q| q["label"] == "직종 더 보기" }
    assert_equal "조리원", more["extra"]["keyword"]

    post_to JOBS, payload(extra: more["extra"])

    assert_includes outputs.first.dig("simpleText", "text"), "11~"
    assert_includes list_items.map { |i| i["title"] }.join, "주방"
  end

  test "a representative with spaces expands too" do
    create_cases("자동차 조립원", 2)
    create_cases("자동차부품조립", 1)
    create_cases("용접공", 1)

    post_to JOBS, payload(params: { keyword: "자동차 조립원" })

    assert_equal [ "자동차 조립원", "자동차부품조립" ], list_items.map { |i| i["title"] }
  end

  test "a word that is not a representative still searches by its tokens" do
    create_cases("형틀목공", 2)

    post_to JOBS, payload(params: { keyword: "형틀" })

    assert_equal [ "형틀목공" ], list_items.map { |i| i["title"] }
  end

  test "the representative path needs no keyword context because Kakao fills the parameter from the entity" do
    post_to JOBS, payload(params: { keyword: "조리원" }, contexts: [])

    assert_equal "조리원", list_items.first["title"]
  end
end
