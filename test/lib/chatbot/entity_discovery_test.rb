# frozen_string_literal: true

require "test_helper"

class Chatbot::EntityDiscoveryTest < ActiveSupport::TestCase
  def builder
    Chatbot::EntityBuilder.new({
      "column" => "disease_name",
      "concepts" => { "회전근개 파열" => { "db" => [ "회전근개 파열" ], "colloquial" => [] } }
    })
  end

  def discovery = Chatbot::EntityDiscovery.new(builder)

  def create_cases(names)
    names.each_with_index { |name, i| DiseaseCase.create!(case_no: "ED-#{SecureRandom.hex(3)}-#{i}", disease_name: name, year: 2024) }
  end

  test "fragments split compound values and strip side words and numbering" do
    fragments = discovery.fragments("우측 견관절 회전근개 파열/좌측 요추 제4-5번간 추간판 탈출증, 양측 손목터널증후군")

    assert_equal [ "견관절 회전근개 파열", "요추 추간판 탈출증", "손목터널증후군" ], fragments
  end

  test "side stripping does not damage words that merely start with 우 or 좌" do
    fragments = discovery.fragments("우울증/좌골신경통/좌 견관절 충돌증후군")

    assert_equal [ "우울증", "좌골신경통", "견관절 충돌증후군" ], fragments
  end

  test "anatomy-only fragments are ignored" do
    assert_empty discovery.fragments("요추/경추 제3번/우측 견관절")
  end

  test "call lists uncovered fragments by number of cases, once per case" do
    create_cases([ "우측 회전근개 파열", "급성 심근경색/급성 심근경색", "좌측 급성 심근경색", "고혈압" ])

    result = discovery.call(min_count: 1)

    assert_includes result, [ "급성 심근경색", 2 ] # 같은 판정서에 두 번 나와도 1건
    assert_includes result, [ "고혈압", 1 ]
    assert_not result.any? { |fragment, _| fragment.include?("회전근개") }, "사전이 덮는 조각은 제외"
  end

  test "call applies min_count and limit and orders by count" do
    create_cases([ "심방세동", "심방세동", "심방세동", "폐렴", "폐렴", "고혈압" ])

    assert_equal [ [ "심방세동", 3 ], [ "폐렴", 2 ] ], discovery.call(min_count: 2)
    assert_equal [ [ "심방세동", 3 ] ], discovery.call(min_count: 1, limit: 1)
  end

  test "blank disease names are skipped" do
    create_cases([ "" ])

    assert_empty discovery.call(min_count: 1)
  end
end
