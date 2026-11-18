# frozen_string_literal: true

require "test_helper"

class SolarExtraction::Tasks::PriorCareerTest < ActiveSupport::TestCase
  setup do
    @task = SolarExtraction::Tasks.fetch("prior_career")
    @input = @task.build_input(
      "medical_records" => "특이사항 없음",
      "recognized_facts" => "입사 전 근무이력: 2005.3.~2010.2. 용접 업무에 종사하였고 2010.3.~2012.6. 물류센터에서 상하차 작업을 하였다.",
      "committee_decision" => nil
    )
  end

  def career(overrides = {})
    { "start_ym" => "2005-03", "end_ym" => "2010-02", "occupation" => "7 기능원 및 관련 기능 종사자", "task" => "용접",
      "evidence_quote" => "2005.3.~2010.2. 용접 업무에 종사하였고" }.merge(overrides)
  end

  def output(careers: [ career ], mention: "있음", months: 60)
    { "mention" => mention, "prior_career_months" => months, "careers" => careers }
  end

  test "올바른 출력은 통과한다" do
    assert_empty @task.validate(output, @input).errors
  end

  test "근거 문장이 입력의 부분 문자열이 아니면 오류" do
    result = @task.validate(output(careers: [ career("evidence_quote" => "2005년부터 용접공으로 일함") ]), @input)
    assert_includes result.errors, "careers[0]: evidence_quote가 입력에 없습니다"
  end

  test "occupation enum, 연월 형식, 순서, task 길이" do
    errors = @task.validate(output(careers: [ career("occupation" => "10 기타", "start_ym" => "2005-13", "task" => "가" * 41) ]), @input).errors
    assert_includes errors, "careers[0]: occupation이 허용 목록에 없습니다"
    assert_includes errors, "careers[0].start_ym: YYYY-MM 형식이 아닙니다"
    assert(errors.any? { |e| e.include?("task가 40자를 넘습니다") })

    reversed = @task.validate(output(careers: [ career("start_ym" => "2010-05", "end_ym" => "2009-01") ]), @input).errors
    assert_includes reversed, "careers[0]: 시작이 끝보다 늦습니다"
  end

  test "연월은 null 허용" do
    assert_empty @task.validate(output(careers: [ career("start_ym" => nil, "end_ym" => nil) ]), @input).errors
  end

  test "언급없음이면 careers와 개월 수가 비어야 한다" do
    ok = output(careers: [], mention: "언급없음", months: nil)
    assert_empty @task.validate(ok, @input).errors
    bad = @task.validate(output(careers: [ career ], mention: "언급없음", months: 12), @input).errors
    assert_includes bad, "mention=언급없음인데 careers가 있습니다"
    assert_includes bad, "mention=언급없음인데 prior_career_months가 있습니다"
  end

  test "mention과 개월 수 범위" do
    assert_includes @task.validate(output(mention: "아마"), @input).errors, "mention 값이 허용 목록에 없습니다"
    assert(@task.validate(output(months: -1), @input).errors.any? { |e| e.include?("prior_career_months") })
    assert(@task.validate(output(months: "60"), @input).errors.any? { |e| e.include?("prior_career_months") })
  end

  test "스키마는 strict 요구사항을 지킨다" do
    items = @task.json_schema.dig(:properties, :careers, :items)
    assert_equal false, items[:additionalProperties]
    assert_equal items[:properties].keys.map(&:to_s).sort, items[:required].sort
    assert_equal false, @task.json_schema[:additionalProperties]
  end

  test "레지스트리" do
    assert_equal %w[comorbidity prior_career], SolarExtraction::Tasks.names
    assert_raises(ArgumentError) { SolarExtraction::Tasks.fetch("nope") }
  end
end
