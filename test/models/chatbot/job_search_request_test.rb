# frozen_string_literal: true

require "test_helper"

class Chatbot::JobSearchRequestTest < ActiveSupport::TestCase
  Request = Chatbot::JobSearchRequest

  def payload(extra: nil, params: {}, utterance: nil, contexts: nil)
    {
      "userRequest" => { "utterance" => utterance },
      "contexts" => contexts,
      "action" => { "params" => params, "clientExtra" => extra }
    }.compact
  end

  def awaiting = [ { "name" => "job_kw", "lifespan" => 1 } ]

  # --- 검색어 출처 ---

  test "the utterance is the keyword only while the keyword context is active" do
    request = Request.new(payload(utterance: "조리", contexts: awaiting))

    assert_equal "조리", request.keyword
    assert_equal :utterance, request.source
  end

  test "an utterance without the keyword context is not a keyword" do
    [ nil, [], [ { "name" => "other" } ] ].each do |contexts|
      request = Request.new(payload(utterance: "날씨 알려줘", contexts: contexts))

      assert_nil request.keyword, contexts.inspect
      assert_equal :none, request.source
    end
  end

  test "an explicit keyword parameter needs no context" do
    request = Request.new(payload(params: { "keyword" => "용접" }, utterance: "다른 말"))

    assert_equal "용접", request.keyword
    assert_equal :param, request.source
  end

  test "the keyword carried in clientExtra wins over the parameter and the utterance" do
    request = Request.new(payload(extra: { "keyword" => "조리" }, params: { "keyword" => "용접" }, utterance: "청소", contexts: awaiting))

    assert_equal "조리", request.keyword
    assert_equal :extra, request.source
  end

  test "the keyword is cleaned" do
    assert_equal "조리 용접", Request.new(payload(params: { "keyword" => " 조리,  용접! " })).keyword
  end

  # --- 선택 ---

  test "picking adds a job to the selection and keeps the earlier choices" do
    request = Request.new(payload(extra: { "keyword" => "조리", "selected" => [ "조리원" ], "pick" => "조리사" }))

    assert_equal %w[조리원 조리사], request.selected
    assert_not request.cap_reached?
  end

  test "picking a selected job again removes it, ignoring spaces" do
    request = Request.new(payload(extra: { "selected" => [ "조리 원", "조리사" ], "pick" => "조리원" }))

    assert_equal %w[조리사], request.selected
  end

  test "selection is capped and tells so" do
    selected = (1..Request::MAX_SELECTED).map { |i| "직종#{i}" }
    request = Request.new(payload(extra: { "selected" => selected, "pick" => "새직종" }))

    assert_equal selected, request.selected
    assert request.cap_reached?
  end

  test "removing a job at the cap is still possible" do
    selected = (1..Request::MAX_SELECTED).map { |i| "직종#{i}" }
    request = Request.new(payload(extra: { "selected" => selected, "pick" => "직종3" }))

    assert_equal 9, request.selected.size
    assert_not request.cap_reached?
  end

  test "selected names are cleaned, de-duplicated and unresolved references are dropped" do
    request = Request.new(payload(extra: { "selected" => [ "조리원", "조리 원", "#wiz1.job", "$job", "", nil, 5, "용접공" ] }))

    assert_equal %w[조리원 용접공], request.selected
  end

  test "an unresolved reference cannot be picked" do
    assert_empty Request.new(payload(extra: { "pick" => "#wiz1.job_name" })).selected
  end

  # --- 쪽 ---

  test "page is clamped" do
    assert_equal 0, Request.new(payload(extra: { "page" => -3 })).page
    assert_equal Request::MAX_PAGE, Request.new(payload(extra: { "page" => 999 })).page
    assert_equal 0, Request.new(payload).page
  end

  # --- 비정상 입력 ---

  test "malformed payloads do not raise" do
    [ nil, [], "text", {}, { "action" => "x" }, { "action" => { "params" => "x", "clientExtra" => "y" } }, { "contexts" => "x" } ].each do |bad|
      request = Request.new(bad)

      assert_nil request.keyword, bad.inspect
      assert_empty request.selected
      assert_equal 0, request.page
    end
  end
end
