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
    assert_includes errors, "careers[0].start_ym: YYYY-MM(월 미상은 YYYY) 형식이 아닙니다"
    assert(errors.any? { |e| e.include?("task가 40자를 넘습니다") })

    reversed = @task.validate(output(careers: [ career("start_ym" => "2010-05", "end_ym" => "2009-01") ]), @input).errors
    assert_includes reversed, "careers[0]: 시작이 끝보다 늦습니다"
  end

  test "연월은 null 허용" do
    assert_empty @task.validate(output(careers: [ career("start_ym" => nil, "end_ym" => nil) ]), @input).errors
  end

  test "월 미상은 YYYY로 받고 개월 수는 nil, 구간은 남는다" do
    year_only = career("start_ym" => "1990", "end_ym" => "1999")
    result = @task.validate(output(careers: [ year_only, career ]), @input)
    assert_empty result.errors
    assert_nil result.output["prior_career_months"]
    assert_equal 2, result.output["careers"].size
    assert_nil @task.compute_months("있음", [ career("start_ym" => "1990-05", "end_ym" => "1999") ])
    assert_equal 12, @task.compute_months("있음", [ career("start_ym" => "2005-03", "end_ym" => "2006-02") ])
  end

  test "연만 있는 구간의 시작·끝 순서 검사는 연 단위로 한다" do
    same_year = career("start_ym" => "1990-05", "end_ym" => "1990")
    assert_empty @task.validate(output(careers: [ same_year ]), @input).errors
    reversed = career("start_ym" => "1991", "end_ym" => "1990-12")
    assert_includes @task.validate(output(careers: [ reversed ]), @input).errors, "careers[0]: 시작이 끝보다 늦습니다"
    bad_format = career("start_ym" => "1990-?")
    assert(@task.validate(output(careers: [ bad_format ]), @input).errors.any? { |e| e.include?("형식이 아닙니다") })
  end

  test "판정서 표기(점·슬래시·일 포함)의 날짜는 YYYY-MM으로 맞춘다" do
    loose = career("start_ym" => "2005.03", "end_ym" => "2010.02.28")
    result = @task.validate(output(careers: [ loose ]), @input)
    assert_empty result.errors
    assert_equal [ "2005-03", "2010-02" ], [ result.output["careers"][0]["start_ym"], result.output["careers"][0]["end_ym"] ]
    assert_equal 60, result.output["prior_career_months"]
    assert_equal "2005-03", @task.validate(output(careers: [ career("start_ym" => "2005/3") ]), @input).output["careers"][0]["start_ym"]
    assert(@task.validate(output(careers: [ career("start_ym" => "2005.13") ]), @input).errors.any? { |e| e.include?("형식이 아닙니다") })
  end

  test "법인 전환·고용승계·재입사 표지가 있는 구간은 same_employer_marker로 표시하고 invalid로 하지 않는다" do
    input = @task.build_input("medical_records" => nil, "committee_decision" => nil,
                              "recognized_facts" => "2005.3.~2010.2. 가 업체에서 근무하다 법인 전환으로 상호가 바뀌었고 2010.3. 재입사하였다.")
    marked = career("evidence_quote" => "2005.3.~2010.2. 가 업체에서 근무하다 법인 전환으로 상호가 바뀌었고")
    result = @task.validate(output(careers: [ marked ]), input)
    assert_empty result.errors
    assert_includes result.output["review_flags"].map { |f| f["rule"] }, "same_employer_marker"
    plain = @task.validate(output, @input)
    assert_not_includes plain.output["review_flags"].map { |f| f["rule"] }, "same_employer_marker"
  end

  test "프롬프트는 현 사업장 규칙과 월 미상 표기를 안내한다" do
    prompt = @task.system_prompt
    assert_includes prompt, "법인 전환"
    assert_includes prompt, "고용승계"
    assert_includes prompt, "재입사"
    assert_includes prompt, '"YYYY"'
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

  def flag_input(text)
    @task.build_input("medical_records" => nil, "recognized_facts" => text, "committee_decision" => nil)
  end

  def flags(result) = result.output["review_flags"]

  test "깨끗한 출력은 review_flags가 빈 배열이다" do
    result = @task.validate(output, @input)
    assert_empty result.errors
    assert_equal [], flags(result)
  end

  test "종료 시점이 없고 근거가 진행 중이면 invalid" do
    text = "2012.7.부터 현재까지 같은 사업장에서 근무하고 있다. 2005.3.~2010.2. 용접."
    careers = [ career("start_ym" => "2012-07", "end_ym" => nil, "evidence_quote" => "2012.7.부터 현재까지 같은 사업장에서 근무하고 있다") ]
    errors = @task.validate(output(careers: careers), flag_input(text)).errors
    assert_includes errors, "careers[0]: 종료 시점이 없고 근거 문장이 진행 중이라 현 사업장 경력으로 보입니다"

    open_ended = [ career("start_ym" => "2005-03", "end_ym" => nil, "evidence_quote" => "2005.3.~2010.2. 용접") ]
    assert_empty @task.validate(output(careers: open_ended), flag_input(text)).errors
    ended = [ career("start_ym" => "2012-07", "end_ym" => "2013-01", "evidence_quote" => "2012.7.부터 현재까지 같은 사업장에서 근무하고 있다") ]
    assert_empty @task.validate(output(careers: ended), flag_input(text)).errors
  end

  test "현재 사업장 입사 전이라는 설명은 진행 중 표현으로 보지 않는다" do
    text = "1995년~2000년 건설현장 일용 (현재 사업장 입사 전)"
    careers = [ career("start_ym" => nil, "end_ym" => nil, "evidence_quote" => text) ]
    assert_empty @task.validate(output(careers: careers), flag_input(text)).errors
    text2 = "2010.3.~현재 재직 중"
    open_ended = [ career("start_ym" => "2010-03", "end_ym" => nil, "evidence_quote" => text2) ]
    assert_includes @task.validate(output(careers: open_ended), flag_input(text2)).errors,
                    "careers[0]: 종료 시점이 없고 근거 문장이 진행 중이라 현 사업장 경력으로 보입니다"
  end

  test "현 사업장 시작 이후에 시작하거나 걸친 구간은 flag" do
    text = "2005.3.~2010.2. 용접. 2012.7.부터 현 사업장에서 근무. 2013.1.~2014.6. 배관."
    after = career("start_ym" => "2013-01", "end_ym" => "2014-06", "evidence_quote" => "2013.1.~2014.6. 배관")
    overlap = career("start_ym" => "2011-01", "end_ym" => "2012-12", "evidence_quote" => "2012.7.부터 현 사업장에서 근무")
    result = @task.validate(output(careers: [ career("evidence_quote" => "2005.3.~2010.2. 용접"), after, overlap ]), flag_input(text))
    assert_empty result.errors
    assert_equal [ [ "starts_after_current_start", [ 1 ] ], [ "overlaps_current_start", [ 2 ] ] ], flags(result).map { |f| [ f["rule"], f["career_indexes"] ] }
  end

  test "입사 날짜는 가장 늦은 것을 현 사업장으로 보고 이전 직장 자신의 입사일은 flag하지 않는다" do
    text = "2005.3. 가업체 입사, 2010.2. 퇴사. 2010.3. 나업체 입사, 2012.6. 퇴사. 2013.1.~2014.1. 다."
    first = career("evidence_quote" => "2005.3. 가업체 입사, 2010.2. 퇴사")
    second = career("start_ym" => "2010-03", "end_ym" => "2012-06", "evidence_quote" => "2010.3. 나업체 입사, 2012.6. 퇴사")
    assert_empty flags(@task.validate(output(careers: [ first, second ]), flag_input(text)))
    after = career("start_ym" => "2013-01", "end_ym" => "2014-01", "evidence_quote" => "2013.1.~2014.1. 다")
    assert_equal [ "starts_after_current_start" ], flags(@task.validate(output(careers: [ first, second, after ]), flag_input(text))).map { |f| f["rule"] }
  end

  test "고용형태 변경 표지가 한 문장에 있거나 이어지는 구간의 고용형태가 다르면 flag" do
    text = "2011.7.~2014.3. 월급제 근로자. 2014.4.~2016.6. 같은 업체에서 프리랜서. 2017.1.~2018.1. 정규직에서 계약직으로 전환."
    a = career("start_ym" => "2011-07", "end_ym" => "2014-03", "evidence_quote" => "2011.7.~2014.3. 월급제 근로자")
    b = career("start_ym" => "2014-04", "end_ym" => "2016-06", "evidence_quote" => "2014.4.~2016.6. 같은 업체에서 프리랜서")
    c = career("start_ym" => "2017-01", "end_ym" => "2018-01", "evidence_quote" => "2017.1.~2018.1. 정규직에서 계약직으로 전환")
    result = @task.validate(output(careers: [ a, b, c ]), flag_input(text))
    assert_empty result.errors
    found = flags(result).select { |f| f["rule"] == "employment_type_change" }.map { |f| f["career_indexes"] }
    assert_includes found, [ 0, 1 ] # 이어지는 구간, 월급제 -> 프리랜서
    assert_includes found, [ 1 ]    # 같은 업체 + 고용형태
    assert_includes found, [ 2 ]    # 전환 + 둘 이상
    far = career("start_ym" => "2020-01", "end_ym" => "2020-12", "evidence_quote" => "2011.7.~2014.3. 월급제 근로자")
    assert_empty flags(@task.validate(output(careers: [ a, far ]), flag_input(text))).select { |f| f["career_indexes"].size == 2 }
  end

  test "고용형태가 한 번만 나오고 이어지지 않으면 flag하지 않는다" do
    text = "2005.3.~2010.2. 일용직으로 용접. 2012.1.~2013.1. 계약직 상하차."
    a = career("evidence_quote" => "2005.3.~2010.2. 일용직으로 용접")
    b = career("start_ym" => "2012-01", "end_ym" => "2013-01", "evidence_quote" => "2012.1.~2013.1. 계약직 상하차")
    assert_empty flags(@task.validate(output(careers: [ a, b ]), flag_input(text)))
  end

  test "검증기 버전과 review_flags 형식" do
    assert_equal "prior_career-v4", @task.validator_version
  end

  test "프롬프트는 현 사업장 제외와 없음 규칙을 담고 개월 수는 요구하지 않는다" do
    assert_includes @task.system_prompt, "현재 사업장"
    assert_includes @task.system_prompt, "이전 근무경력: 무"
    assert_not_includes @task.json_schema[:properties].keys, :prior_career_months
    assert_equal "prior_career-p4", @task.prompt_version
    assert_equal "prior_career-s3", @task.schema_version
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
