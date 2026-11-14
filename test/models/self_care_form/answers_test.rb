# frozen_string_literal: true

require "test_helper"

class SelfCareForm::AnswersTest < ActiveSupport::TestCase
  Answers = SelfCareForm::Answers

  test "a situation, a decision and a body part button are validated against the allowed values" do
    answers = Answers.new
    answers.apply("situation", value: "ill")
    answers.apply("body_part", value: "손목")
    answers.apply("decision", value: "approved")

    assert_equal "ill", answers["situation"]
    assert_equal "손목", answers["body_part"]
    assert_equal "approved", answers["decision"]

    answers.apply("situation", value: "ghost")
    answers.apply("body_part", value: "존재하지않는부위")
    answers.apply("decision", value: "승인")
    assert_equal "ill", answers["situation"], "허용값 밖은 무시한다"
    assert_equal "손목", answers["body_part"]
    assert_equal "approved", answers["decision"]
  end

  test "skipping the situation clears it" do
    answers = Answers.new("situation" => "ill")
    answers.apply("situation", value: "skip")
    assert_nil answers["situation"]
  end

  test "free text and a button exclude each other and free text is cut at 30 characters" do
    answers = Answers.new
    answers.apply("job", value: "택배기사")
    answers.apply("job", free_text: "배달" * 40)

    assert_nil answers["job"]
    assert_equal 30, answers["job_text"].length

    answers.apply("job", value: "용접공")
    assert_equal "용접공", answers["job"]
    assert_nil answers["job_text"]
  end

  test "none and skip clear both the button and the free text" do
    answers = Answers.new("body_part" => "손목", "body_part_text" => "왼쪽")
    answers.apply("body_part", value: "none")
    assert_nil answers["body_part"]
    assert_nil answers["body_part_text"]

    answers.apply("decision", value: "all")
    assert_equal "all", answers["decision"]
    answers.apply("decision", value: "skip")
    assert_nil answers["decision"], "건너뛰면 저장하지 않는다(모두 보기와 구분)"
  end

  test "profile takes all four values at once, validates each and treats missing or invalid as no answer" do
    answers = Answers.new
    answers.apply("profile", respondent: "유가족", application_experience: "불승인을 받음", age_band: "10대", region: "서울")
    assert_equal({ "respondent" => "유가족", "application_experience" => "불승인을 받음", "age_band" => "10대", "region" => "서울" },
      answers.to_h.slice(*Answers::PROFILE_KEYS))

    answers.apply("profile", respondent: "본인", age_band: "200대", region: "화성")
    assert_equal "본인", answers["respondent"]
    assert_nil answers["application_experience"], "누락 = 답하지 않음"
    assert_nil answers["age_band"], "허용값 밖 = 답하지 않음"
    assert_nil answers["region"]

    answers.skip_profile
    assert_empty answers.to_h.slice(*Answers::PROFILE_KEYS)
  end

  test "unknown session keys are dropped when loading" do
    answers = Answers.from_session("situation" => "ill", "hacker" => "x")
    assert_equal({ "situation" => "ill" }, answers.to_h)
    assert_empty Answers.from_session("garbage").to_h
  end

  test "the worst case stays far below the cookie limit" do
    answers = Answers.new
    answers.apply("situation", value: "no_time")
    answers.apply("body_part", free_text: "가" * 40)
    answers.apply("job", free_text: "나" * 40)
    answers.apply("decision", value: "revised_approved")
    answers.apply("profile", respondent: "피해 노동자의 가족", application_experience: "불승인을 받음", age_band: "60대 이상", region: "충남")

    assert_operator answers.to_h.to_json.bytesize, :<, 600
  end

  test "search conditions: a button expands to keywords and tokens, free text wins over a button" do
    answers = Answers.new("body_part" => "손목", "job" => "택배기사", "decision" => "rejected")
    conditions = answers.search_conditions

    assert_equal Chatbot::BodyPartExpansion.tokens_for("손목"), conditions.body_tokens
    assert_equal [ "택배" ], conditions.job_name_any
    assert_nil conditions.job_name
    assert_equal "rejected", conditions.decision

    text = Answers.new("job" => "택배기사", "job_text" => "배달", "decision" => "all").search_conditions
    assert_equal "배달", text.job_name
    assert_nil text.job_name_any, "직접 입력이 우선"
    assert_nil text.decision, "모두 보기는 필터 없음"
  end

  test "search conditions: typed body part is matched to a concept, an unknown one is dropped with a flag" do
    matched = Answers.new("body_part_text" => "왼쪽 손목").search_conditions
    assert_equal "손목", matched.body_concept
    assert_equal Chatbot::BodyPartExpansion.tokens_for("손목"), matched.body_tokens
    refute matched.body_unmatched

    unmatched = Answers.new("body_part_text" => "등산 중 다침").search_conditions
    assert_nil unmatched.body_tokens
    assert unmatched.body_unmatched
  end
end
