# frozen_string_literal: true

require "test_helper"

class Chatbot::KakaoResponseBuilderTest < ActiveSupport::TestCase
  Builder = Chatbot::KakaoResponseBuilder

  def item_for(attrs = {})
    record = DiseaseCase.create!({ case_no: "KB-#{SecureRandom.hex(4)}", disease_name: "회전근개파열",
      result: "approved", year: 2024 }.merge(attrs))
    public_case = Chatbot::PublicCase.new(record)
    result = Chatbot::CaseSearch::Result.new(cases: [ public_case ], total_count: 1, over_cap: false,
      used_fallback: false, has_more: false, page: 0)
    conditions = Chatbot::KakaoRequestAdapter::Conditions.new(disease_name: "x", ignored: [])
    Builder.results(result, conditions).dig(:template, :outputs).last.dig(:listCard, :items, 0)
  end

  test "limits match the Kakao listCard spec (header 15, title 30, description 16)" do
    assert_equal [ 15, 30, 16 ], [ Builder::LIST_HEADER_LIMIT, Builder::LIST_ITEM_TITLE_LIMIT, Builder::LIST_ITEM_DESCRIPTION_LIMIT ],
      "main_notions/setup_answer.md '말풍선 제작 스펙 정보'의 리스트형 규격"
  end

  # --- 제목(30자): 직업명 · 신청인 주장 ---

  test "title joins the job name and the applicant claim" do
    assert_equal "조립원 · 허리 통증", item_for(job_name: "조립원", applicant_claim: "허리 통증")[:title]
  end

  test "the claim fills the rest of the title and ends with an ellipsis when it is long" do
    item = item_for(job_name: "조립원", applicant_claim: "과거에는 청소 재활용 차를 타면서 물건을 들고 던지고를 반복적으로 많이 수행하였고")

    # 잘린 자리가 공백이면 말줄임표 앞 공백을 지우므로 한도(30자)보다 한두 글자 짧을 수 있다.
    assert_includes 28..30, item[:title].length
    assert item[:title].start_with?("조립원 · 과거에는 청소 재활용"), item[:title]
    assert item[:title].end_with?("…")
  end

  test "a long job name is cut to ten characters so the claim keeps its room" do
    item = item_for(job_name: "건설 및 광업 단순 종사원과 기타 서비스 관련 종사원", applicant_claim: "장기간 갱내외에서 과도한 근력의 사용으로 발병")

    assert item[:title].start_with?("건설 및 광업 단… · 장기간 갱내외에서"), item[:title]
    assert_operator item[:title].length, :<=, Builder::LIST_ITEM_TITLE_LIMIT
  end

  test "title is the claim alone when there is no job name" do
    assert_equal "허리 통증", item_for(applicant_claim: "허리 통증")[:title]
  end

  test "title is the job name alone when there is no usable claim" do
    assert_equal "조립원", item_for(job_name: "조립원")[:title]
    assert_equal "조립원", item_for(job_name: "조립원", applicant_claim: "신청인 주장")[:title]
  end

  test "the disease name is only a last resort when the title would otherwise be empty" do
    assert_equal "회전근개파열", item_for[:title]
    assert_equal "회전근개파열", item_for(applicant_claim: "신청인 주장")[:title]
    assert_no_match(/회전근개파열/, item_for(job_name: "조립원", applicant_claim: "허리 통증")[:title], "직업명이나 주장이 있으면 질병명은 쓰지 않는다")
  end

  test "title starts from the substance, not from bullets, headings and the applicant subject" do
    {
      "○ 신청인은 과거에는 청소 재활용 차를 타면서 물건을 들었다" => "과거에는 청소 재활용 차를 타면서 물건을 들었다",
      "가. 신청인 주장 - 신청인은 2010년 3월부터 요양병원에서 근무" => "2010년 3월부터 요양병원에서 근무",
      "청구인은 고인이 광업소에서 근무 시 유해물질에 노출되어" => "고인이 광업소에서 근무 시 유해물질에 노출되어",
      "가. 신청인 주장 ○ (휴게시간)신청인의 수면장소는 경비초소" => "(휴게시간)신청인의 수면장소는 경비초소",
      "<신청인의 주장> - 과로와 스트레스, 업무수행 중 세균 감염" => "과로와 스트레스, 업무수행 중 세균 감염",
      "- 신청인의 주요 주장은 2017년 5월부터 내 재해사업장에서" => "2017년 5월부터 내 재해사업장에서",
      "1) 신청인 주장 ○ 신청인은 교대근무 등 과도한 업무" => "교대근무 등 과도한 업무"
    }.each do |claim, expected|
      assert_equal expected, item_for(applicant_claim: claim)[:title], claim
    end
  end

  test "a claim that starts with a date keeps the date intact" do
    [ "2018.5.1.부터 근로자 숙소 자재 정리와 청소를 계속 하였고", "2020. 8. 6.부터 (주)○○○○○에서 근무를 하면서" ].each do |claim|
      assert item_for(applicant_claim: claim)[:title].start_with?(claim[0, 20]), claim
    end
  end

  test "masked names are kept instead of being mistaken for bullets" do
    assert_equal "○○○○○에서는 2002년까지 벤젠을 사용", item_for(applicant_claim: "○ 신청인 주장 - ○○○○○에서는 2002년까지 벤젠을 사용")[:title]
    assert_equal "○○○○○ 공판장 돼지 도축", item_for(applicant_claim: "○○○○○ 공판장 돼지 도축")[:title]
  end

  test "personal numbers in the claim are masked before they reach the list" do
    title = item_for(applicant_claim: "010-1234-5678 로 연락")[:title]

    assert_no_match(/010-1234-5678/, title)
    assert_includes title, "***"
  end

  test "no ellipsis is ever preceded by a space" do
    title = item_for(job_name: "조립원", applicant_claim: "가나다라마바사아자차카타파하 거너더러머버서어저처커터퍼허 고노도로모보소오조")[:title]

    assert title.end_with?("…")
    assert_no_match(/\s…\z/, title)
  end

  # --- 설명(16자): 승인여부·신체부위 ---

  test "description joins the decision and the body parts without spaces" do
    assert_equal "불인정·어깨,허리", item_for(result: "rejected", burden_body_part: "어깨|허리")[:description]
  end

  test "description does not repeat the job name that is already in the title" do
    item = item_for(burden_body_part: "어깨", job_name: "조립원")

    assert_equal "인정·어깨", item[:description]
    assert item[:title].start_with?("조립원")
  end

  test "description uses the label of every decision" do
    labels = { "approved" => "인정", "rejected" => "불인정", "partially_approved" => "일부인정", "revised_approved" => "변경인정" }

    labels.each do |result, label|
      assert_equal "#{label}·어깨", item_for(result: result, burden_body_part: "어깨")[:description]
    end
  end

  test "description is just the decision when there is no body part" do
    assert_equal "인정", item_for[:description]
    assert_equal "불인정", item_for(result: "rejected", burden_body_part: "", job_name: "조립원")[:description]
    assert_no_match(/회전근개파열/, item_for[:description], "질병명으로 보완하지 않는다")
  end

  test "body parts drop left/right prefixes, merge duplicates and keep the first three" do
    assert_equal "인정·어깨", item_for(burden_body_part: "우측 어깨|좌측 어깨|양측 어깨")[:description]
    assert_equal "인정·어깨,목,팔", item_for(burden_body_part: "어깨|목|팔|허리")[:description]
    assert_equal "인정·어깨,견관절", item_for(burden_body_part: "우 어깨|좌 견관절")[:description]
  end

  test "stripping a side prefix does not damage words that merely start with 우 or 좌" do
    assert_equal "인정·좌골,우울", item_for(burden_body_part: "좌골|우울")[:description]
  end

  test "description never exceeds the limit and the decision always survives" do
    item = item_for(result: "revised_approved", burden_body_part: "가나다라마바사아자차카타파하")

    assert item[:description].start_with?("변경인정·"), item[:description]
    assert item[:description].end_with?("…")
    assert_operator item[:description].length, :<=, Builder::LIST_ITEM_DESCRIPTION_LIMIT
    assert_no_match(/\s…\z/, item[:description])
  end

  # --- 링크: 근로복지공단 판정서 사이트 ---

  test "item links to the Comwel case page and has no buttons" do
    item = item_for(case_no: "240020200002638")

    assert_equal({ web: "https://jilbyungcase.comwel.or.kr/service/dataView?id=240020200002638" }, item[:link])
    assert_nil item[:buttons]
  end

  test "item uses the stored link when the record has one" do
    link = "https://jilbyungcase.comwel.or.kr/service/dataView?id=740020210001916"

    assert_equal({ web: link }, item_for(case_no: "740020210001916", link: link)[:link])
  end
end
