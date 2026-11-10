# frozen_string_literal: true

require "test_helper"

class DiseaseCases::NormalizerTest < ActiveSupport::TestCase
  N = DiseaseCases::Normalizer

  def result(column, value) = N.public_send(column, value).then { [ it.value, it.detail ] }

  test "blank_to_nil turns nil, empty, whitespace-only and zero-width values into nil" do
    [ nil, "", "   ", " ", "　", "​" ].each { |v| assert_nil N.blank_to_nil(v), v.inspect }
    assert_equal "Y", N.blank_to_nil(" Y ")
  end

  test "enum_value keeps allowed values and nils blanks and unknown values" do
    assert_equal "Y", N.enum_value(:death_status, "Y")
    assert_nil N.enum_value(:death_status, "")
    assert_nil N.enum_value(:death_status, "모름")
    assert_equal "매우_높음", N.enum_value(:work_relevance_eval, "매우_높음")
    assert_nil N.enum_value(:work_relevance_eval, "")
  end

  test "application_type unifies form-name suffixes" do
    %w[요양급여 요양급여신청서 요양신청서 요양신청 최초요양급여신청서 요양신청소견서].each do |raw|
      assert_equal [ "요양급여", nil ], result(:application_type, raw), raw
    end
    %w[유족급여 유족급여청구서 유족급여신청서 유족보상청구서].each do |raw|
      assert_equal [ "유족급여", nil ], result(:application_type, raw), raw
    end
  end

  test "application_type joins tokens with a fixed order" do
    [ "유족급여 및 장의비청구서", "유족급여, 장의비", "유족급여/장의비", "장의비 및 유족급여", "진폐유족연금 및 장의비" ].each do |raw|
      assert_equal [ "유족급여|장의비", nil ], result(:application_type, raw), raw
    end
    assert_equal [ "요양급여|휴업급여", nil ], result(:application_type, "요양급여, 휴업급여")
    assert_equal [ "요양급여|추가상병", nil ], result(:application_type, "추가상병 요양급여")
  end

  test "application_type keeps parenthetical remarks in detail and honors token-named parentheses" do
    assert_equal [ "유족급여", "추정" ], result(:application_type, "유족급여(추정)")
    assert_equal [ "추가상병", "폐암" ], result(:application_type, "추가상병신청(폐암)")
    assert_equal [ "요양급여|미지급보험급여", nil ], result(:application_type, "요양급여(미지급보험급여)")
  end

  test "application_type without a token becomes 기타 and keeps the original" do
    assert_equal [ "기타", "업무상 질병 판정" ], result(:application_type, "업무상 질병 판정")
  end

  test "work_type unifies spacing and word order" do
    [ "고정주간근무", "고정 주간근무", "주간고정근무", "주간근무" ].each do |raw|
      assert_equal [ "고정주간근무", nil ], result(:work_type, raw), raw
    end
  end

  test "work_type moves time and parenthetical text to detail" do
    assert_equal [ "고정주간근무", "08:00~17:00" ], result(:work_type, "고정주간근무 (08:00~17:00)")
    assert_equal [ "고정주간근무", "08:00~17:00, 주 5일" ], result(:work_type, "고정주간근무 (08:00~17:00, 주 5일)")
    assert_equal [ "교대근무", "오전/오후/야간조" ], result(:work_type, "교대근무 (오전/오후/야간조)")
  end

  test "work_type keeps the full original in detail when other wording is mixed in" do
    assert_equal [ "교대근무", "4조 3교대" ], result(:work_type, "4조 3교대")
    assert_equal [ "격일근무", "24시간 격일제 교대근무" ], result(:work_type, "24시간 격일제 교대근무")
  end

  test "work_type without a shift keyword becomes 기타 with the original in detail" do
    assert_equal [ "기타", "주 5일 근무 (09:00~18:00)" ], result(:work_type, "주 5일 근무 (09:00~18:00)")
  end

  test "employment_type picks the first keyword and keeps remarks in detail" do
    assert_equal [ "정규직", nil ], result(:employment_type, "정규직")
    assert_equal [ "정규직", "상용" ], result(:employment_type, "정규직(상용)")
    assert_equal [ "정규직", "4대보험 가입" ], result(:employment_type, "정규직(4대보험 가입)")
    assert_equal [ "상용직", nil ], result(:employment_type, "상용")
    assert_equal [ "일용직", nil ], result(:employment_type, "일용근로")
  end

  test "employment_type 정규직 and 상용직 stay separate and 비정규직 is 기타" do
    assert_equal [ "상용직", "상용/정규직" ], result(:employment_type, "상용/정규직")
    assert_equal [ "기타", "비정규직" ], result(:employment_type, "비정규직")
    assert_equal [ "기타", "4대보험" ], result(:employment_type, "4대보험")
  end

  test "blank input gives nil value and nil detail for every column" do
    %i[application_type work_type employment_type].each do |column|
      [ nil, "", "  " ].each { |v| assert_equal [ nil, nil ], result(column, v) }
    end
  end

  test "normalizing is idempotent: standard values pass through unchanged" do
    %i[application_type work_type employment_type].each do |column|
      %w[요양급여|휴업급여 유족급여|장의비 기타 고정주간근무 교대근무 정규직 상용직].each do |standard|
        first = N.public_send(column, standard)
        next unless first.value == standard

        assert_equal [ standard, nil ], result(column, standard), "#{column} #{standard}"
      end
    end
    assert_equal [ "기타", nil ], result(:work_type, "기타")
    assert_equal [ "요양급여|휴업급여", nil ], result(:application_type, "요양급여|휴업급여")
  end
end
