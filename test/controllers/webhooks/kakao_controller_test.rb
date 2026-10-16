# frozen_string_literal: true

require "test_helper"

class Webhooks::KakaoControllerTest < ActionDispatch::IntegrationTest
  setup do
    @original_allow_blank_token = Webhooks::KakaoController.allow_blank_token
    @original_token = ENV["KAKAO_SKILL_TOKEN"]
    ENV.delete("KAKAO_SKILL_TOKEN")
  end

  teardown do
    Webhooks::KakaoController.allow_blank_token = @original_allow_blank_token
    ENV["KAKAO_SKILL_TOKEN"] = @original_token
  end

  def skill_payload(params: {}, client_extra: nil, utterance: "사용자 발화 원문")
    {
      userRequest: {
        timezone: "Asia/Seoul", block: { id: "block-1", name: "판정 사례 검색" }, utterance: utterance, lang: "ko",
        user: { id: "bot-user-1", type: "botUserKey", properties: { plusfriendUserKey: "pf-1" } }
      },
      contexts: [],
      bot: { id: "bot-1", name: "산재상담실" },
      action: { name: "case_search", clientExtra: client_extra, params: params, id: "skill-1", detailParams: {} }
    }
  end

  def post_skill(payload, headers: {})
    post "/webhooks/kakao", params: payload.to_json, headers: { "CONTENT_TYPE" => "application/json" }.merge(headers)
  end

  def create_case(case_no, attrs = {})
    DiseaseCase.create!({ case_no: case_no, disease_name: "회전근개파열", result: "approved", year: 2024,
      job_name: "자동차 부품 조립원", job_description: "어깨 반복 작업", job_tenure_months: 144 }.merge(attrs))
  end

  def outputs = response.parsed_body.dig("template", "outputs")
  def list_cards = outputs.filter_map { |output| output["listCard"] }
  def list_items = list_cards.flat_map { |card| card["items"] }
  def quick_replies = response.parsed_body.dig("template", "quickReplies")

  test "extracts conditions from the Kakao action key, not Rails params[:action]" do
    create_case("TEST-KK-CUFF", disease_name: "회전근개파열")
    create_case("TEST-KK-BACK", disease_name: "허리디스크")

    post_skill(skill_payload(params: { disease_name: "회전근개파열" }))

    assert_response :success
    assert_equal "2.0", response.parsed_body["version"]
    items = list_items
    assert_equal 1, items.size
    assert_equal "자동차 부품 조립원", items.first["title"], "신청인 주장이 없으면 직업명만 쓴다"
    assert_equal "인정", items.first["description"], "신체부위가 없으면 승인여부만 보인다"
    assert_match "TEST-KK-CUFF", items.first.dig("link", "web")
    assert_match "검색 조건: 질병 회전근개파열", outputs.first.dig("simpleText", "text")
  end

  test "applies disease, job, work factor and decision filters together" do
    create_case("TEST-KK-MATCH", disease_name: "회전근개파열", result: "rejected", job_description: "어깨 팔 거상 작업")
    create_case("TEST-KK-OTHER-RESULT", disease_name: "회전근개파열", result: "approved", job_description: "어깨 팔 거상 작업")
    create_case("TEST-KK-OTHER-DISEASE", disease_name: "허리디스크", result: "rejected", job_description: "어깨 팔 거상 작업")

    post_skill(skill_payload(params: { disease_name: "회전근개", job_name: "조립", work_factor: "거상", decision_type: "불인정" }))

    items = list_items
    assert_equal 1, items.size
    assert_match "TEST-KK-MATCH", items.first.dig("link", "web")
    assert_match "불인정", items.first["description"]
  end

  test "each list item links to the Comwel case page" do
    create_case("TEST-KK-LINK")

    post_skill(skill_payload(params: { disease_name: "회전근개" }))

    assert_equal({ "web" => "https://jilbyungcase.comwel.or.kr/service/dataView?id=TEST-KK-LINK" }, list_items.first["link"])
    assert_nil list_items.first["buttons"], "항목 자체가 링크라 버튼은 없다"
  end

  test "always includes the approval-probability disclaimer with results" do
    create_case("TEST-KK-DISCLAIMER")

    post_skill(skill_payload(params: { disease_name: "회전근개" }))

    assert_includes outputs.first.dig("simpleText", "text"), Chatbot::KakaoResponseBuilder::DISCLAIMER
  end

  test "pages through results ten at a time in listCards of five and carries conditions in the quick reply extra" do
    12.times { |i| create_case("TEST-KK-PAGE-#{i}", year: 2024 - i) }

    post_skill(skill_payload(params: { disease_name: "회전근개", decision_type: "인정" }))

    assert_equal 3, outputs.size, "요약 + listCard 2장"
    assert_equal [ 5, 5 ], list_cards.map { |card| card["items"].size }
    assert_equal [ "1~5번째 사례", "6~10번째 사례" ], list_cards.map { |card| card.dig("header", "title") }
    more = quick_replies.find { |q| q["label"] == "다른 사례 보기" }
    assert_not_nil more
    assert_equal "message", more["action"]
    assert_equal({ "disease_name" => "회전근개", "decision_type" => "approved", "page" => 1 }, more["extra"])
    assert_includes outputs.first.dig("simpleText", "text"), "총 12건 중 1~10번째"

    post_skill(skill_payload(params: {}, client_extra: more["extra"]))

    assert_equal 2, outputs.size
    assert_equal [ 2 ], list_cards.map { |card| card["items"].size }
    assert_equal [ "11~12번째 사례" ], list_cards.map { |card| card.dig("header", "title") }
    assert_nil quick_replies.find { |q| q["label"] == "다른 사례 보기" }
    assert_includes outputs.first.dig("simpleText", "text"), "총 12건 중 11~12번째"
  end

  test "five or fewer results fit in a single listCard" do
    5.times { |i| create_case("TEST-KK-FIVE-#{i}", year: 2024 - i) }

    post_skill(skill_payload(params: { disease_name: "회전근개" }))

    assert_equal 2, outputs.size
    assert_equal [ 5 ], list_cards.map { |card| card["items"].size }
    assert_equal [ "1~5번째 사례" ], list_cards.map { |card| card.dig("header", "title") }
  end

  test "a lone sixth result gets a singular header" do
    6.times { |i| create_case("TEST-KK-SIX-#{i}", year: 2024 - i) }

    post_skill(skill_payload(params: { disease_name: "회전근개" }))

    assert_equal [ "1~5번째 사례", "6번째 사례" ], list_cards.map { |card| card.dig("header", "title") }
    assert_equal [ 5, 1 ], list_cards.map { |card| card["items"].size }
  end

  test "reports no result without implying a decision and offers a way back" do
    post_skill(skill_payload(params: { disease_name: "존재하지않는질병" }))

    assert_response :success
    assert_equal 1, outputs.size
    assert_match "찾지 못했습니다", outputs.first.dig("simpleText", "text")
    assert_equal %w[조건\ 바꾸기 처음으로], quick_replies.map { |q| q["label"] }
  end

  test "asks for conditions when none were extracted" do
    post_skill(skill_payload(params: {}))

    assert_response :success
    assert_match "알려주세요", outputs.first.dig("simpleText", "text")
  end

  test "drops an unknown decision type and tells the user" do
    create_case("TEST-KK-IGNORED")

    post_skill(skill_payload(params: { disease_name: "회전근개", decision_type: "아마도" }))

    assert_equal 1, list_items.size
    assert_match "판정 결과 조건은 인식하지 못해 제외", outputs.first.dig("simpleText", "text")
  end

  test "malformed JSON still returns a valid skill response" do
    post "/webhooks/kakao", params: "{not json", headers: { "CONTENT_TYPE" => "application/json" }

    assert_response :success
    assert_equal "2.0", response.parsed_body["version"]
  end

  test "unexpected errors return a fallback skill response with HTTP 200" do
    Chatbot::CaseSearch.class_eval do
      alias_method :original_call, :call
      define_method(:call) { raise "boom" }
    end

    post_skill(skill_payload(params: { disease_name: "회전근개" }))

    assert_response :success
    assert_equal "2.0", response.parsed_body["version"]
    assert_match "일시적인 문제", outputs.first.dig("simpleText", "text")
  ensure
    Chatbot::CaseSearch.class_eval do
      alias_method :call, :original_call
      remove_method :original_call
    end
  end

  test "response respects Kakao template limits" do
    12.times { |i| create_case("TEST-KK-LIMIT-#{i}", disease_name: "가" * 80, job_name: "나" * 200, year: 2000 + i) }

    post_skill(skill_payload(params: { disease_name: "가" * 80 }))

    assert_operator outputs.size, :<=, 3
    assert_operator quick_replies.size, :<=, 10
    assert_operator outputs.first.dig("simpleText", "text").length, :<=, 1000
    assert_equal 10, list_items.size, "한 번에 10건"
    list_cards.each do |card|
      assert_operator card["items"].size, :<=, Chatbot::KakaoResponseBuilder::LIST_ITEMS_PER_CARD
      assert_operator card.dig("header", "title").length, :<=, Chatbot::KakaoResponseBuilder::LIST_HEADER_LIMIT
      card["items"].each do |item|
        assert_operator item["title"].length, :<=, Chatbot::KakaoResponseBuilder::LIST_ITEM_TITLE_LIMIT
        assert_operator item["description"].length, :<=, Chatbot::KakaoResponseBuilder::LIST_ITEM_DESCRIPTION_LIMIT
        assert item["link"]["web"].start_with?("http"), "링크는 절대 URL"
      end
    end
  end

  test "the page size never needs more than the three outputs Kakao allows" do
    assert_operator Chatbot::CaseSearch::PAGE_SIZE, :<=, Chatbot::KakaoResponseBuilder::LIST_ITEMS_PER_CARD * 2,
      "요약 simpleText 1개 + listCard 2장 = outputs 3개가 한도"
  end

  test "logs counts and timing but never the utterance or extracted values" do
    create_case("TEST-KK-LOG")
    io = StringIO.new
    Rails.logger.broadcast_to(Logger.new(io))

    post_skill(skill_payload(params: { disease_name: "회전근개파열" }, utterance: "비밀스러운발화원문"))

    kakao_lines = io.string.lines.select { |line| line.include?("kakao_search") }
    assert_equal 1, kakao_lines.size
    assert_no_match(/회전근개|비밀스러운발화원문|bot-user-1/, kakao_lines.first)
    assert_match(/"result_count":1/, kakao_lines.first)
  ensure
    Rails.logger.stop_broadcasting_to(Rails.logger.broadcasts.last) if Rails.logger.respond_to?(:broadcasts) && Rails.logger.broadcasts.size > 1
  end

  # --- 인증 ---

  test "rejects requests with a wrong or missing token when a token is configured" do
    ENV["KAKAO_SKILL_TOKEN"] = "s3cret"

    post_skill(skill_payload(params: { disease_name: "회전근개" }))
    assert_response :unauthorized

    post_skill(skill_payload(params: { disease_name: "회전근개" }), headers: { "X-Skill-Token" => "wrong" })
    assert_response :unauthorized
  end

  test "accepts requests with the configured token" do
    ENV["KAKAO_SKILL_TOKEN"] = "s3cret"

    post_skill(skill_payload(params: { disease_name: "회전근개" }), headers: { "X-Skill-Token" => "s3cret" })

    assert_response :success
  end

  test "fails closed when no token is configured and blank tokens are not allowed" do
    Webhooks::KakaoController.allow_blank_token = false

    post_skill(skill_payload(params: { disease_name: "회전근개" }))

    assert_response :unauthorized
  end

  test "does not require a CSRF token" do
    original = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true

    post_skill(skill_payload(params: {}))

    assert_response :success
  ensure
    ActionController::Base.allow_forgery_protection = original
  end
end
