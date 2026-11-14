# frozen_string_literal: true

require "test_helper"

class SelfCareForm::FlowTest < ActiveSupport::TestCase
  Flow = SelfCareForm::Flow

  test "the question steps are exactly the five screens, in order, and next/previous follow them" do
    assert_equal %w[situation body_part job decision profile], Flow::STEP_KEYS
    assert_equal "body_part", Flow.next_step("situation")
    assert_equal "review", Flow.next_step("profile")
    assert_equal "start", Flow.previous_step("situation")
    assert_equal "profile", Flow.previous_step("review")
  end

  test "only question screens are numbered; start, review and result have no number" do
    assert_equal [ 1, 2, 3, 4, 5 ], Flow::STEP_KEYS.map { |k| Flow.question_number(k) }
    assert_equal 5, Flow.question_count
    assert_nil Flow.question_number("review")
    assert_nil Flow.question_number("start")
    assert_nil Flow.question_number("result")
  end

  test "removed steps do not exist: gender, employment type, work type, municipality and KSCO" do
    %w[gender employment_type work_type region_detail ksco respondent].each do |key|
      refute Flow.step?(key), "#{key}는 질문 단계가 아니다(respondent는 profile 안의 한 항목)"
    end
    assert_includes Flow::PROFILE_FIELDS.keys, "respondent"
    refute_includes Flow::PROFILE_FIELDS.keys, "gender"
  end

  test "job groups cover exactly the 54 chatbot dictionary jobs with no duplicates" do
    dictionary = Chatbot::EntityDictionary.concepts("job_name").keys.sort
    grouped = Flow::JOB_NAMES.map { |name| Chatbot::EntityDictionary.normalize(name) }

    assert_equal 54, dictionary.size
    assert_equal dictionary, grouped.sort, "사전에 직종이 늘거나 줄면 소제목 묶음을 고친다"
    assert_equal grouped.uniq.size, grouped.size
    assert_equal 5, Flow::JOB_GROUPS.size
  end

  test "every job button has search keywords in the dictionary" do
    Flow::JOB_NAMES.each do |name|
      assert Chatbot::JobExpansion.stems_for(name).present?, "#{name}의 핵심어"
    end
  end

  test "body part buttons are the 19 dictionary concepts" do
    assert_equal 19, Flow.body_part_names.size
    assert_includes Flow.body_part_names, "손목"
  end

  test "decision choices are the enum values plus all, and labels come from the DB labels" do
    assert_equal %w[approved rejected partially_approved revised_approved all], Flow::DECISION_KEYS
    assert_equal "인정", Flow.decision_label("approved")
    assert_equal "불인정", Flow.decision_label("rejected")
    assert_equal "일부인정", Flow.decision_label("partially_approved")
    assert_equal "변경인정", Flow.decision_label("revised_approved")
    assert_equal "모두 보기", Flow.decision_label("all")
  end

  test "the labels sent to the google form are the Flow labels" do
    assert_equal [ "이미 아픈 곳이 있어요", "아직 아프지 않지만 예방하려고 알아봐요", "병원 갈 시간이 없어 먼저 알아보고 있어요" ],
      Flow::SITUATIONS.values
    assert_equal 17, Flow::PROFILE_FIELDS["region"].size
    assert_includes Flow::PROFILE_FIELDS["age_band"], "10대"
    assert_includes Flow::PROFILE_FIELDS["application_experience"], "불승인을 받음"
  end
end
