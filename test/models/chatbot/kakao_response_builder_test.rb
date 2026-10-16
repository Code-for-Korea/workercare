# frozen_string_literal: true

require "test_helper"

class Chatbot::KakaoResponseBuilderTest < ActiveSupport::TestCase
  Builder = Chatbot::KakaoResponseBuilder

  def item_for(attrs = {})
    record = DiseaseCase.create!({ case_no: "KB-#{SecureRandom.hex(4)}", disease_name: "회전근개파열",
      result: "approved", year: 2024 }.merge(attrs))
    public_case = Chatbot::PublicCase.new(record, base_url: "https://example.test")
    result = Chatbot::CaseSearch::Result.new(cases: [ public_case ], total_count: 1, over_cap: false,
      used_fallback: false, has_more: false, page: 0)
    conditions = Chatbot::KakaoRequestAdapter::Conditions.new(disease_name: "x", ignored: [])
    Builder.results(result, conditions).dig(:template, :outputs).last.dig(:listCard, :items, 0)
  end

  test "limits match the Kakao listCard spec (header 15, title 30, description 16)" do
    assert_equal [ 15, 30, 16 ], [ Builder::LIST_HEADER_LIMIT, Builder::LIST_ITEM_TITLE_LIMIT, Builder::LIST_ITEM_DESCRIPTION_LIMIT ],
      "main_notions/setup_answer.md '말풍선 제작 스펙 정보'의 리스트형 규격"
  end

  # --- 제목: 승인여부 · 신체부위 · 직업명 ---

  test "title joins the decision, body parts and job name" do
    item = item_for(result: "rejected", burden_body_part: "어깨|허리", job_name: "조립원")

    assert_equal "불인정 · 어깨,허리 · 조립원", item[:title]
  end

  test "title uses the label of every decision" do
    labels = { "approved" => "인정", "rejected" => "불인정", "partially_approved" => "일부인정", "revised_approved" => "변경인정" }

    labels.each do |result, label|
      assert_equal "#{label} · 어깨 · 조립원", item_for(result: result, burden_body_part: "어깨", job_name: "조립원")[:title]
    end
  end

  test "title skips a missing part" do
    assert_equal "인정 · 조립원", item_for(job_name: "조립원")[:title]
    assert_equal "인정 · 어깨", item_for(burden_body_part: "어깨")[:title]
  end

  test "title falls back to the disease name when there is neither a body part nor a job" do
    assert_equal "인정 · 회전근개파열", item_for[:title]
  end

  test "body parts drop left/right prefixes, merge duplicates and keep the first two" do
    assert_equal "인정 · 어깨", item_for(burden_body_part: "우측 어깨|좌측 어깨|양측 어깨", job_name: nil)[:title]
    assert_equal "인정 · 어깨,목", item_for(burden_body_part: "어깨|목|팔|허리", job_name: nil)[:title]
    assert_equal "인정 · 어깨,견관절", item_for(burden_body_part: "우 어깨|좌 견관절", job_name: nil)[:title]
  end

  test "stripping a side prefix does not damage words that merely start with 우 or 좌" do
    assert_equal "인정 · 좌골,우울", item_for(burden_body_part: "좌골|우울", job_name: nil)[:title]
  end

  test "title never exceeds the limit and shortens the last part instead of cutting a word in the middle" do
    item = item_for(result: "partially_approved", burden_body_part: "어깨|허리", job_name: "건설 및 광업 단순 종사원과 기타 서비스 관련 단순 종사원")

    assert_operator item[:title].length, :<=, Builder::LIST_ITEM_TITLE_LIMIT
    assert item[:title].start_with?("일부인정 · 어깨,허리 · 건설"), item[:title]
    assert item[:title].end_with?("…")
    assert_no_match(/\s…\z/, item[:title], "말줄임표 앞에 공백이 남으면 안 된다")
  end

  # --- 설명: 신청인 주장 ---

  test "description shows the claim as far as the limit allows" do
    item = item_for(applicant_claim: "장기간 갱내외에서 과도한 근력을 쓰는 작업을 수행하였다")

    assert_equal 16, item[:description].length
    assert_equal "장기간 갱내외에서 과도한 근…", item[:description]
  end

  test "a short claim is shown whole without an ellipsis" do
    assert_equal "허리 통증", item_for(applicant_claim: "허리 통증")[:description]
  end

  test "description starts from the substance, not from bullets and the applicant subject" do
    {
      "○ 신청인은 과거에는 청소 재활용 차를 타면서 물건을 들었다" => "과거에는 청소 재활용 차를…",
      "가. 신청인 주장 - 신청인은 2010년 3월부터 요양병원에서 근무" => "2010년 3월부터 요양병원…",
      "청구인은 고인이 광업소에서 근무 시 유해물질에 노출되어" => "고인이 광업소에서 근무 시…"
    }.each do |claim, expected|
      assert_equal expected, item_for(applicant_claim: claim)[:description], claim
    end
  end

  test "description falls back to the case number when there is no usable claim" do
    assert_equal "KB-NOCLAIM", item_for(case_no: "KB-NOCLAIM")[:description]
    assert_equal "KB-LEADONLY", item_for(case_no: "KB-LEADONLY", applicant_claim: "신청인 주장")[:description]
  end

  test "personal numbers in the claim are masked before they reach the list" do
    description = item_for(applicant_claim: "010-1234-5678 로 연락")[:description]

    assert_no_match(/010-1234-5678/, description)
    assert_includes description, "***"
  end

  test "item links to the case page and has no buttons" do
    item = item_for(case_no: "KB-LINK")

    assert_equal({ web: "https://example.test/disease_cases/KB-LINK" }, item[:link])
    assert_nil item[:buttons]
  end
end
