# frozen_string_literal: true

require "test_helper"

class SolarExtraction::Tasks::ComorbidityTest < ActiveSupport::TestCase
  setup do
    @task = SolarExtraction::Tasks.fetch("comorbidity")
    @input = @task.build_input(
      "medical_records" => "고혈압으로 약물치료 중이며\n   당뇨는 없음. 흡연 20년. 연락처 010-1234-5678",
      "recognized_facts" => "재해자는 술을 마시지 않는다.",
      "committee_decision" => "기왕증인 퇴행성 변화가 주된 원인이다."
    )
  end

  def field(value, quote, mention) = { "value" => value, "evidence_quote" => quote, "mention" => mention }

  def valid_output
    {
      "comorbidities" => field([ "고혈압" ], "고혈압으로 약물치료 중", "있음"),
      "smoking" => field("현재", "흡연 20년", "있음"),
      "alcohol" => field("비음주", "술을 마시지 않는다", "없음"),
      "source" => field("위원회 판단", "기왕증인 퇴행성 변화가 주된 원인이다", "있음")
    }
  end

  test "입력은 세 컬럼만 이름 붙인 절로 잇고 PIIMasking을 돌리지 않는다" do
    assert_includes @input, "[의학적 소견]"
    assert_includes @input, "[인정 사실]"
    assert_includes @input, "[위원회 판단]"
    assert_includes @input, "010-1234-5678"
    assert_nil @task.build_input("medical_records" => " ", "recognized_facts" => nil, "committee_decision" => "")
    assert_not_includes @task.build_input("medical_records" => "a", "statement" => "진술"), "진술"
  end

  test "올바른 출력은 통과한다" do
    result = @task.validate(valid_output, @input)
    assert_empty result.errors
  end

  test "공백·줄바꿈이 달라도 근거 문장은 일치로 본다" do
    output = valid_output.merge("comorbidities" => field([ "당뇨" ], "고혈압으로   약물치료 중이며 당뇨는 없음", "있음"))
    assert_empty @task.validate(output, @input).errors
  end

  test "검증에 실패한 근거 문장도 번호 형태는 가려지고 80자로 잘려 저장된다" do
    quote = "모델이 지어낸 문장 010-1234-5678 주민번호 800101-1234567 " + ("가" * 100)
    output = valid_output.merge("smoking" => field("현재", quote, "있음"))
    result = @task.validate(output, @input)
    stored = result.output["smoking"]["evidence_quote"]

    assert_includes result.errors, "smoking: evidence_quote가 입력에 없습니다"
    assert_not_includes stored, "010-1234-5678"
    assert_not_includes stored, "1234567"
    assert_operator stored.length, :<=, SolarExtraction::Tasks::Base::QUOTE_MAX
  end

  test "입력에 없는 근거 문장은 invalid 사유로 남는다" do
    output = valid_output.merge("smoking" => field("현재", "하루 한 갑씩 피웠다", "있음"))
    result = @task.validate(output, @input)
    assert_includes result.errors, "smoking: evidence_quote가 입력에 없습니다"
  end

  test "근거 문장이 80자를 넘으면 오류" do
    long = "가" * 81
    output = valid_output.merge("smoking" => field("현재", long, "있음"))
    assert(@task.validate(output, @input).errors.any? { |e| e.include?("80자를 넘습니다") })
  end

  test "enum 밖의 값과 mention 값은 오류" do
    output = valid_output.merge("comorbidities" => field([ "암" ], "고혈압으로 약물치료 중", "있음"), "smoking" => field("가끔", "흡연 20년", "있음"))
    errors = @task.validate(output, @input).errors
    assert_includes errors, "comorbidities: 허용 목록에 없는 값이 있습니다"
    assert_includes errors, "smoking: 허용 목록에 없는 값입니다"
    bad_mention = valid_output.merge("alcohol" => field("비음주", "술을 마시지 않는다", "아마"))
    assert_includes @task.validate(bad_mention, @input).errors, "alcohol: mention 값이 허용 목록에 없습니다"
  end

  test "언급없음은 빈 값과 빈 근거여야 한다" do
    ok = valid_output.merge("alcohol" => field("미확인", "", "언급없음"), "comorbidities" => field([], "", "언급없음"))
    assert_empty @task.validate(ok, @input).errors

    bad = valid_output.merge("alcohol" => field("음주", "", "언급없음"))
    assert_includes @task.validate(bad, @input).errors, "alcohol: 언급없음인데 값이 미확인이 아닙니다"
    with_quote = valid_output.merge("alcohol" => field("미확인", "술을 마시지 않는다", "언급없음"))
    assert_includes @task.validate(with_quote, @input).errors, "alcohol: 언급없음인데 evidence_quote가 있습니다"
  end

  test "값이 미확인인데 mention=있음이면 오류" do
    output = valid_output.merge("smoking" => field("미확인", "흡연 20년", "있음"))
    errors = @task.validate(output, @input).errors
    assert_includes errors, "smoking: mention=있음인데 값이 미확인입니다"
    assert_includes errors, "smoking: 값이 미확인인데 evidence_quote가 있습니다"
  end

  test "미확인·빈 값은 근거를 달 수 없다" do
    quoted = valid_output.merge("alcohol" => field("미확인", "술을 마시지 않는다", "없음"))
    assert_includes @task.validate(quoted, @input).errors, "alcohol: mention=없음인데 값이 비음주가 아닙니다"
    source = valid_output.merge("source" => field("언급없음", "기왕증인 퇴행성 변화가 주된 원인이다", "없음"))
    assert_includes @task.validate(source, @input).errors, "source: 값이 언급없음인데 evidence_quote가 있습니다"
    empty_list = valid_output.merge("comorbidities" => field([], "고혈압으로 약물치료 중", "있음"))
    assert_includes @task.validate(empty_list, @input).errors, "comorbidities: mention=있음인데 비어 있습니다"
    list_none = valid_output.merge("comorbidities" => field([ "고혈압" ], "고혈압으로 약물치료 중", "없음"))
    assert_includes @task.validate(list_none, @input).errors, "comorbidities: mention=없음인데 값이 있습니다"
  end

  test "프롬프트·스키마 버전과 일치 규칙 문구" do
    assert_equal "comorbidity-p2", @task.prompt_version
    assert_equal "comorbidity-s2", @task.schema_version
    assert_includes @task.system_prompt, "직접 뒷받침"
    assert_includes @task.system_prompt, "오래된 건강검진 문진표"
    assert_equal SolarExtraction::Tasks::Base::DEFAULT_MAX_TOKENS, @task.max_tokens
  end

  test "있음인데 근거가 비면 오류" do
    output = valid_output.merge("smoking" => field("현재", "", "있음"))
    assert_includes @task.validate(output, @input).errors, "smoking: evidence_quote가 비어 있습니다"
  end

  test "통과한 근거 문장의 번호 형태는 검증 뒤에 가려서 저장한다" do
    output = valid_output.merge("smoking" => field("현재", "흡연 20년. 연락처 010-1234-5678", "있음"))
    result = @task.validate(output, @input)
    assert_empty result.errors
    assert_equal "흡연 20년. 연락처 ***", result.output["smoking"]["evidence_quote"]
  end

  test "키가 빠지거나 객체가 아니면 오류" do
    result = @task.validate(valid_output.except("source"), @input)
    assert(result.errors.any? { |e| e.start_with?("최상위 키가 맞지 않습니다") })
    assert_equal [ "출력이 객체가 아닙니다" ], @task.validate("x", @input).errors
  end

  test "스키마는 strict 요구사항을 지킨다" do
    schema = @task.json_schema
    walk = lambda do |node|
      next unless node.is_a?(Hash)

      if node[:type] == "object"
        assert_equal false, node[:additionalProperties]
        assert_equal node[:properties].keys.map(&:to_s).sort, node[:required].sort
      end
      node.each_value { |v| v.is_a?(Array) ? v.each { |x| walk.call(x) } : walk.call(v) }
    end
    walk.call(schema)
    assert_equal "object", schema[:type]
  end
end
