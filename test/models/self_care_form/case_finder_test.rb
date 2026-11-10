# frozen_string_literal: true

require "test_helper"

class SelfCareForm::CaseFinderTest < ActiveSupport::TestCase
  Conditions = SelfCareForm::Answers::Conditions

  def conditions(**overrides)
    Conditions.new(**{ body_tokens: nil, body_concept: nil, body_unmatched: false,
      job_name_any: nil, job_name: nil, decision: nil }.merge(overrides))
  end

  setup do
    @a = DiseaseCase.create!(case_no: "TEST-CF-A", disease_name: "가", job_name: "택배원", burden_body_part: "손목",
      result: "approved", year: 2024)
    @b = DiseaseCase.create!(case_no: "TEST-CF-B", disease_name: "나", job_name: "택배원", burden_body_part: "손목",
      result: "rejected", year: 2023)
    @c = DiseaseCase.create!(case_no: "TEST-CF-C", disease_name: "다", job_name: "조리원", burden_body_part: "손목",
      result: "approved", year: 2022)
    @d = DiseaseCase.create!(case_no: "TEST-CF-D", disease_name: "라", job_name: "택배원", burden_body_part: "허리",
      result: "approved", year: 2021)
  end

  def numbers(result) = result.records.map(&:case_no).grep(/TEST-CF-/)

  def sql_count
    count = 0
    callback = lambda { |*, payload| count += 1 if payload[:sql].match?(/\A\s*SELECT/i) && payload[:name] != "SCHEMA" }
    ActiveSupport::Notifications.subscribed(callback, "sql.active_record") { yield }
    count
  end

  test "all conditions that match are returned newest first with no condition dropped" do
    result = SelfCareForm::CaseFinder.new(conditions(body_tokens: [ "손목" ], job_name_any: [ "택배" ], decision: "approved")).call

    assert_equal %w[TEST-CF-A], numbers(result)
    assert_empty result.dropped
    assert_equal 1, result.total_count
    refute result.over_cap
  end

  test "zero results drops the decision first, then the job, and keeps the body part" do
    nothing_for_cooks_in_the_back = conditions(body_tokens: [ "허리" ], job_name_any: [ "조리" ], decision: "rejected")
    result = SelfCareForm::CaseFinder.new(nothing_for_cooks_in_the_back).call

    assert_equal [ :decision, :job ], result.dropped
    assert_equal %w[TEST-CF-D], numbers(result), "신체부위(허리)는 끝까지 유지된다"
    assert_nil result.conditions.decision
    assert_nil result.conditions.job_name_any
    assert_equal [ "허리" ], result.conditions.body_tokens
  end

  test "dropping only the decision is enough when the job still matches" do
    result = SelfCareForm::CaseFinder.new(conditions(body_tokens: [ "허리" ], job_name_any: [ "택배" ], decision: "rejected")).call

    assert_equal [ :decision ], result.dropped
    assert_equal %w[TEST-CF-D], numbers(result)
    assert_equal [ "택배" ], result.conditions.job_name_any, "결과를 낸 시도의 조건만 남는다"
  end

  test "only the job is dropped when no decision was chosen" do
    result = SelfCareForm::CaseFinder.new(conditions(body_tokens: [ "손목" ], job_name: "없는직업")).call

    assert_equal [ :job ], result.dropped
    assert_equal %w[TEST-CF-A TEST-CF-B TEST-CF-C], numbers(result)
  end

  test "nothing found even after dropping returns an empty result" do
    result = SelfCareForm::CaseFinder.new(conditions(body_tokens: [ "없는부위" ], job_name_any: [ "택배" ], decision: "approved")).call

    assert_empty result.records
    assert_equal 0, result.total_count
  end

  test "a typed job uses substring matching and the any-keyword list uses OR" do
    typed = SelfCareForm::CaseFinder.new(conditions(job_name: "택배")).call
    assert_includes numbers(typed), "TEST-CF-A"
    refute_includes numbers(typed), "TEST-CF-C"

    any = SelfCareForm::CaseFinder.new(conditions(job_name_any: %w[택배 조리])).call
    assert_equal %w[TEST-CF-A TEST-CF-B TEST-CF-C TEST-CF-D], numbers(any)
  end

  test "SQL statements stay within attempts plus the row read and one count" do
    worst = conditions(body_tokens: [ "허리" ], job_name_any: [ "조리" ], decision: "rejected")
    assert_operator sql_count { SelfCareForm::CaseFinder.new(worst).call }, :<=, 5

    first_hit = conditions(body_tokens: [ "손목" ])
    assert_operator sql_count { SelfCareForm::CaseFinder.new(first_hit).call }, :<=, 3
  end

  test "the list is found by ids first and only those rows are read in full" do
    selects = []
    callback = lambda { |*, payload| selects << payload[:sql] if payload[:sql].match?(/\A\s*SELECT/i) && payload[:name] != "SCHEMA" }
    result = ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
      SelfCareForm::CaseFinder.new(conditions(body_tokens: [ "손목" ])).call
    end

    id_query, row_query = selects
    assert_match(/\ASELECT "disease_cases"\."id" FROM/, id_query)
    assert_match(/INDEXED BY "#{SelfCareForm::CaseFinder::INDEX_NAME}"/, id_query)
    assert_match(/\ASELECT "disease_cases"\.\* FROM "disease_cases" WHERE "disease_cases"\."id" IN \(/, row_query)
    assert_equal %w[TEST-CF-A TEST-CF-B TEST-CF-C], numbers(result), "year 내림차순"
  end

  test "records with the same year come back newest id first" do
    older = DiseaseCase.create!(case_no: "TEST-CF-T1", job_name: "동점", year: 2019)
    newer = DiseaseCase.create!(case_no: "TEST-CF-T2", job_name: "동점", year: 2019)
    result = SelfCareForm::CaseFinder.new(conditions(job_name: "동점")).call

    assert_equal [ newer.id, older.id ], result.records.map(&:id)
  end

  test "more than ten records sets more and shows ten" do
    11.times { |i| DiseaseCase.create!(case_no: "TEST-CF-M#{i}", job_name: "배관공", year: 2020) }
    result = SelfCareForm::CaseFinder.new(conditions(job_name: "배관공")).call

    assert_equal 10, result.records.size
    assert result.more
    assert_equal 11, result.total_count
  end
end
