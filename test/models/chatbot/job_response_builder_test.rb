# frozen_string_literal: true

require "test_helper"

class Chatbot::JobResponseBuilderTest < ActiveSupport::TestCase
  Builder = Chatbot::JobResponseBuilder
  Candidate = Chatbot::JobCandidates::Candidate

  def candidates(count, prefix: "직종")
    Array.new(count) { |i| Candidate.new(name: "#{prefix}#{i + 1}", count: 100 - i) }
  end

  def build(count: 25, page: 0, selected: [], keyword: "조리", cap_reached: false)
    Builder.candidates(keyword: keyword, candidates: candidates(count), page: page, selected: selected, cap_reached: cap_reached)
  end

  def outputs(body) = body.dig(:template, :outputs)
  def replies(body) = body.dig(:template, :quickReplies)
  def list_cards(body) = outputs(body).filter_map { |o| o[:listCard] }
  def items(body) = list_cards(body).flat_map { |c| c[:items] }
  def text(body) = outputs(body).first.dig(:simpleText, :text)

  test "a page shows ten candidates in two listCards of five after the summary" do
    body = build

    assert_equal "2.0", body[:version]
    assert_equal 3, outputs(body).size
    assert_equal [ 5, 5 ], list_cards(body).map { |c| c[:items].size }
    assert_equal [ "1~5번째 직종", "6~10번째 직종" ], list_cards(body).map { |c| c.dig(:header, :title) }
  end

  test "later pages continue the numbering and a short last page uses one card" do
    body = build(count: 13, page: 1)

    assert_equal 2, outputs(body).size
    assert_equal [ "11~13번째 직종" ], list_cards(body).map { |c| c.dig(:header, :title) }
    assert_equal %w[직종11 직종12 직종13], items(body).map { |i| i[:title] }
  end

  test "a lone last candidate gets a singular header" do
    assert_equal [ "11번째 직종" ], list_cards(build(count: 11, page: 1)).map { |c| c.dig(:header, :title) }
  end

  test "every item picks its job through a fixed message and carries the state in extra" do
    body = build(selected: [ "직종9" ], page: 0, keyword: "조리 용접")
    item = items(body).first

    assert_equal "message", item[:action]
    assert_equal "직종 선택", item[:messageText]
    assert_equal({ "keyword" => "조리 용접", "selected" => [ "직종9" ], "page" => 0, "pick" => "직종1" }, item[:extra])
    assert_equal "100건", item[:description]
  end

  test "selected candidates are marked, ignoring spaces in the selected name" do
    titles = items(build(selected: [ "직종2", "직 종4" ])).first(5).map { |i| i[:title] }

    assert_equal [ "직종1", "✓ 직종2", "직종3", "✓ 직종4", "직종5" ], titles
  end

  test "marking ignores spaces between a selected and a candidate name" do
    body = Builder.candidates(keyword: "조리", candidates: [ Candidate.new(name: "조리 원", count: 3) ], page: 0, selected: [ "조리원" ])

    assert_equal "✓ 조리 원", items(body).first[:title]
  end

  test "the summary shows the keyword, the range and the selection" do
    assert_includes text(build(selected: [ "직종1", "직종2" ])), "'조리'로 찾은 직종 25개 중 1~10번째예요."
    assert_includes text(build(selected: [ "직종1", "직종2" ])), "선택한 직종(2): 직종1, 직종2"
    assert_includes text(build), "선택한 직종이 아직 없어요"
  end

  test "reaching the fetch limit says 'or more'" do
    body = build(count: Chatbot::JobCandidates::FETCH_LIMIT)

    assert_includes text(body), "#{Chatbot::JobCandidates::FETCH_LIMIT}개 이상 중"
  end

  test "the selection cap is explained" do
    assert_includes text(build(cap_reached: true)), "최대 #{Chatbot::JobSearchRequest::MAX_SELECTED}개까지"
    assert_not_includes text(build), "최대 #{Chatbot::JobSearchRequest::MAX_SELECTED}개까지"
  end

  test "quick replies: find only with a selection, more only with a next page, previous only after the first page" do
    plain = replies(build(count: 8)).map { |q| q[:label] }
    assert_equal [ "직종 다시 검색", "처음으로" ], plain

    full = replies(build(count: 25, page: 1, selected: [ "직종1" ])).map { |q| q[:label] }
    assert_equal [ "선택한 직종으로 찾기", "직종 더 보기", "이전 직종", "직종 다시 검색", "처음으로" ], full
  end

  test "the find button hands the chosen names to the case search skill" do
    find = replies(build(selected: [ "직종1", "직종2" ])).find { |q| q[:label] == "선택한 직종으로 찾기" }

    assert_equal "선택한 직종으로 찾기", find[:messageText]
    assert_equal({ "job_names" => [ "직종1", "직종2" ] }, find[:extra])
  end

  test "more and previous keep the keyword and the selection and move one page" do
    body = build(page: 1, selected: [ "직종1" ], keyword: "조리")
    more = replies(body).find { |q| q[:label] == "직종 더 보기" }
    previous = replies(body).find { |q| q[:label] == "이전 직종" }

    assert_equal({ "keyword" => "조리", "selected" => [ "직종1" ], "page" => 2 }, more[:extra])
    assert_equal({ "keyword" => "조리", "selected" => [ "직종1" ], "page" => 0 }, previous[:extra])
    assert_equal "직종 더 보기", more[:messageText]
  end

  test "the response re-arms the keyword context so the user can type again" do
    assert_equal [ { name: "job_kw", lifeSpan: 1, ttl: 600 } ], build.dig(:context, :values)
    assert_equal "job_kw", Chatbot::JobSearchRequest::KEYWORD_CONTEXT
  end

  test "Kakao limits are respected with long names" do
    long = Array.new(12) { |i| Candidate.new(name: "건설 및 광업 단순 종사원과 기타 서비스 관련 종사원#{i}", count: 123_456) }
    body = Builder.candidates(keyword: "건설", candidates: long, page: 0, selected: long.first(10).map(&:name))

    assert_operator outputs(body).size, :<=, 3
    assert_operator replies(body).size, :<=, 10
    assert_operator text(body).length, :<=, Chatbot::KakaoResponseBuilder::TEXT_LIMIT
    list_cards(body).each do |card|
      assert_operator card.dig(:header, :title).length, :<=, Chatbot::KakaoResponseBuilder::LIST_HEADER_LIMIT
      assert_operator card[:items].size, :<=, Chatbot::KakaoResponseBuilder::LIST_ITEMS_PER_CARD
      card[:items].each do |item|
        assert_operator item[:title].length, :<=, Chatbot::KakaoResponseBuilder::LIST_ITEM_TITLE_LIMIT
        assert_operator item[:description].length, :<=, Chatbot::KakaoResponseBuilder::LIST_ITEM_DESCRIPTION_LIMIT
      end
    end
    replies(body).each { |q| assert_operator q[:label].length, :<=, 14 }
  end

  test "page size fits the three outputs Kakao allows" do
    assert_operator Builder::PAGE_SIZE, :<=, Chatbot::KakaoResponseBuilder::LIST_ITEMS_PER_CARD * 2
  end

  test "prompt asks for a job, offers example keywords and re-arms the context" do
    body = Builder.prompt

    assert_includes text(body), "찾고 싶은 직종을 입력해 주세요"
    assert_includes text(body), "개인정보"
    assert_equal %w[조리 용접 청소 경비 운전 처음으로], replies(body).map { |q| q[:label] }
    assert_equal "조리", replies(body).first[:messageText]
    assert_equal "job_kw", body.dig(:context, :values, 0, :name)
  end

  test "prompt can start with a note" do
    assert text(Builder.prompt(note: "두 글자 이상 입력해 주세요.")).start_with?("두 글자 이상 입력해 주세요.")
  end

  test "no_match names the keyword and lets the user try again" do
    body = Builder.no_match("없는직종")

    assert_includes text(body), "'없는직종'에 맞는 직종을 찾지 못했어요"
    assert_equal "처음으로", replies(body).last[:label]
    assert_equal "job_kw", body.dig(:context, :values, 0, :name)
  end

  test "the summary uses the right particle for the last letter of the keyword" do
    { "조리" => "로", "조리원" => "으로", "용접공" => "으로", "서울" => "로", "청소" => "로", "경비원" => "으로", "H2" => "로" }.each do |keyword, particle|
      body = Builder.candidates(keyword: keyword, candidates: candidates(3), page: 0, selected: [])

      assert_includes text(body), "'#{keyword}'#{particle} 찾은 직종", keyword
    end
  end
end
