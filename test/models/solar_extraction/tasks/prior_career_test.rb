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

  def output(careers: [ career ], mention: "있음")
    { "mention" => mention, "careers" => careers }
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

  test "언급없음이면 careers가 비어야 하고 개월 수는 nil" do
    result = @task.validate(output(careers: [], mention: "언급없음"), @input)
    assert_empty result.errors
    assert_nil result.output["prior_career_months"]
    bad = @task.validate(output(careers: [ career ], mention: "언급없음"), @input).errors
    assert_includes bad, "mention=언급없음인데 careers가 있습니다"
  end

  test "이전 경력이 없다고 명시하면 mention=없음, careers 빈 배열, 개월 수 0" do
    result = @task.validate(output(careers: [], mention: "없음"), @input)
    assert_empty result.errors
    assert_equal 0, result.output["prior_career_months"]
    assert_includes @task.validate(output(careers: [ career ], mention: "없음"), @input).errors, "mention=없음인데 careers가 있습니다"
  end

  test "mention=있음인데 careers가 비면 오류" do
    result = @task.validate(output(careers: [], mention: "있음"), @input)
    assert_includes result.errors, "mention=있음인데 careers가 비어 있습니다"
    assert_nil result.output["prior_career_months"]
  end

  test "mention 값이 허용 목록에 없으면 오류" do
    assert_includes @task.validate(output(mention: "아마"), @input).errors, "mention 값이 허용 목록에 없습니다"
  end

  test "개월 수는 모델이 아니라 코드가 구간에서 계산한다(양 끝 포함)" do
    result = @task.validate(output, @input)
    assert_equal 60, result.output["prior_career_months"] # 2005-03 ~ 2010-02
    one = @task.validate(output(careers: [ career("start_ym" => "2005-03", "end_ym" => "2005-03") ]), @input)
    assert_equal 1, one.output["prior_career_months"]
  end

  test "겹치는 구간은 병합하고 떨어진 구간은 합한다" do
    careers = [
      career("start_ym" => "2005-03", "end_ym" => "2006-02"), # 12개월
      career("start_ym" => "2005-09", "end_ym" => "2006-08"), # 겹침: 합집합 2005-03~2006-08 = 18개월
      career("start_ym" => "2008-01", "end_ym" => "2008-06")  # 6개월
    ]
    assert_equal 24, @task.validate(output(careers: careers), @input).output["prior_career_months"]
  end

  test "시작이나 끝이 없는 구간이 있으면 개월 수는 nil" do
    careers = [ career, career("start_ym" => "2011-01", "end_ym" => nil) ]
    result = @task.validate(output(careers: careers), @input)
    assert_empty result.errors
    assert_nil result.output["prior_career_months"]
  end

  test "모델이 개월 수를 내면 키가 맞지 않아 오류" do
    result = @task.validate(output.merge("prior_career_months" => 60), @input)
    assert(result.errors.any? { |e| e.start_with?("최상위 키가 맞지 않습니다") })
  end

  test "careers가 상한을 넘으면 앞에서부터 잘라 검증한다" do
    careers = Array.new(SolarExtraction::Tasks::PriorCareer::MAX_CAREERS + 3) { career }
    result = @task.validate(output(careers: careers), @input)
    assert_empty result.errors
    assert_equal SolarExtraction::Tasks::PriorCareer::MAX_CAREERS, result.output["careers"].size
  end

  test "프롬프트는 현 사업장 제외와 없음 규칙을 담고 개월 수는 요구하지 않는다" do
    assert_includes @task.system_prompt, "현재 사업장"
    assert_includes @task.system_prompt, "이전 근무경력: 무"
    assert_not_includes @task.json_schema[:properties].keys, :prior_career_months
    assert_equal "prior_career-p2", @task.prompt_version
    assert_equal "prior_career-s2", @task.schema_version
  end

  test "출력 토큰 상한은 과제별로 다르다" do
    assert_equal SolarExtraction::Tasks::PriorCareer::MAX_TOKENS, @task.max_tokens
    assert_operator @task.max_tokens, :>, SolarExtraction::Tasks.fetch("comorbidity").max_tokens
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
