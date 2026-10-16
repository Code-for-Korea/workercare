# frozen_string_literal: true

require "test_helper"

class Chatbot::KakaoRequestAdapterTest < ActiveSupport::TestCase
  def payload(params: {}, client_extra: nil, utterance: "발화 원문", detail_params: {})
    {
      "userRequest" => { "utterance" => utterance, "user" => { "id" => "bot-user-1", "type" => "botUserKey" } },
      "action" => { "name" => "case_search", "params" => params, "detailParams" => detail_params, "clientExtra" => client_extra }
    }
  end

  test "reads entity values from action.params" do
    conditions = Chatbot::KakaoRequestAdapter.new(
      payload(params: { "disease_name" => "회전근개파열", "job_name" => "자동차 부품 조립", "work_factor" => "어깨 작업" })
    ).conditions

    assert_equal "회전근개파열", conditions.disease_name
    assert_equal "자동차 부품 조립", conditions.job_name
    assert_equal "어깨 작업", conditions.work_factor
    assert_nil conditions.result
    assert_not conditions.empty?
  end

  test "ignores utterance and detailParams origin" do
    conditions = Chatbot::KakaoRequestAdapter.new(
      payload(params: {}, utterance: "허리디스크 걸렸어요",
        detail_params: { "disease_name" => { "origin" => "허리디스크", "value" => "허리디스크" } })
    ).conditions

    assert conditions.empty?
  end

  test "maps Korean decision labels to enum values" do
    { "인정" => "approved", "불인정" => "rejected", "일부인정" => "partially_approved", "변경인정" => "revised_approved" }.each do |label, enum|
      conditions = Chatbot::KakaoRequestAdapter.new(payload(params: { "decision_type" => label })).conditions
      assert_equal enum, conditions.result, label
      assert_empty conditions.ignored
    end
  end

  test "전체 means no result filter and is not reported as ignored" do
    conditions = Chatbot::KakaoRequestAdapter.new(payload(params: { "disease_name" => "허리디스크", "decision_type" => "전체" })).conditions

    assert_nil conditions.result
    assert_empty conditions.ignored
  end

  test "unknown decision value is dropped and reported as ignored" do
    conditions = Chatbot::KakaoRequestAdapter.new(payload(params: { "disease_name" => "허리디스크", "decision_type" => "아마도인정" })).conditions

    assert_nil conditions.result
    assert_equal [ "decision_type" ], conditions.ignored
  end

  test "continues conditions from clientExtra and lets action.params override them" do
    adapter = Chatbot::KakaoRequestAdapter.new(
      payload(params: { "job_name" => "물류" },
        client_extra: { "disease_name" => "허리디스크", "job_name" => "용접", "decision_type" => "rejected", "page" => 2 })
    )

    assert_equal "허리디스크", adapter.conditions.disease_name
    assert_equal "물류", adapter.conditions.job_name
    assert_equal "rejected", adapter.conditions.result
    assert_equal 2, adapter.page
  end

  test "page is clamped" do
    assert_equal 0, Chatbot::KakaoRequestAdapter.new(payload(client_extra: { "page" => -5 })).page
    assert_equal Chatbot::KakaoRequestAdapter::MAX_PAGE, Chatbot::KakaoRequestAdapter.new(payload(client_extra: { "page" => 99_999 })).page
    assert_equal 0, Chatbot::KakaoRequestAdapter.new(payload).page
  end

  test "values are stripped, blank values dropped and long values truncated" do
    conditions = Chatbot::KakaoRequestAdapter.new(
      payload(params: { "disease_name" => "  허리디스크 ", "job_name" => "   ", "work_factor" => "가" * 500 })
    ).conditions

    assert_equal "허리디스크", conditions.disease_name
    assert_nil conditions.job_name
    assert_equal Chatbot::KakaoRequestAdapter::MAX_VALUE_LENGTH, conditions.work_factor.length
  end

  test "tolerates malformed payloads" do
    [ nil, [], "text", {}, { "action" => "x" }, { "action" => { "params" => "x", "clientExtra" => "y" } } ].each do |bad|
      adapter = Chatbot::KakaoRequestAdapter.new(bad)
      assert adapter.conditions.empty?, bad.inspect
      assert_equal 0, adapter.page
    end
  end

  test "user_key_digest hashes the botUserKey" do
    digest = Chatbot::KakaoRequestAdapter.new(payload).user_key_digest

    assert_equal Digest::SHA256.hexdigest("bot-user-1"), digest
    assert_nil Chatbot::KakaoRequestAdapter.new({}).user_key_digest
  end
end
