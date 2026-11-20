# frozen_string_literal: true

require "test_helper"
require "csv"

class SolarExtraction::GoldSampleTest < ActiveSupport::TestCase
  Row = SolarExtraction::GoldSample::Row

  def population
    rows = []
    { [ "근골격계", "인정" ] => 60, [ "근골격계", "불인정" ] => 40, [ "뇌심혈관", "인정" ] => 20, [ "뇌심혈관", "불인정" ] => 10,
      [ nil, "인정" ] => 6, [ nil, "불인정" ] => 3, [ "기타", "인정" ] => 2 }.each do |(category, result), count|
      count.times { |i| rows << Row.new("#{category || 'N'}-#{result}-#{i}", category, result, 2020 + (i % 3), "https://example.test/#{i}") }
    end
    rows
  end

  test "같은 seed면 같은 표본, 다른 seed면 다른 표본" do
    a = SolarExtraction::GoldSample.new(size: 40, seed: 1).select_rows(population).map(&:case_no)
    b = SolarExtraction::GoldSample.new(size: 40, seed: 1).select_rows(population.reverse).map(&:case_no)
    c = SolarExtraction::GoldSample.new(size: 40, seed: 2).select_rows(population).map(&:case_no)

    assert_equal a, b
    assert_not_equal a.sort, c.sort
  end

  test "정확히 요청한 크기이고 모든 비어 있지 않은 층을 최소 건수 이상 포함한다" do
    sampler = SolarExtraction::GoldSample.new(size: 40, seed: 7, min_per_stratum: 3)
    rows = population
    selected = sampler.select_rows(rows)

    assert_equal 40, selected.size
    assert_equal selected.size, selected.map(&:case_no).uniq.size
    summary = sampler.summary(rows, selected)
    assert_equal 7, summary.size
    summary.each { |key, (pop, picked)| assert_operator picked, :>=, [ 3, pop ].min, "층 #{key}" }
    assert_includes summary.keys, [ "(NULL)", "인정" ]
  end

  test "표본이 모집단보다 크면 전부 낸다" do
    rows = population
    assert_equal rows.size, SolarExtraction::GoldSample.new(size: 1000).select_rows(rows).size
  end

  test "CSV는 BOM과 헤더, 빈 라벨 열을 가지고 본문을 담지 않는다" do
    sampler = SolarExtraction::GoldSample.new(size: 10, seed: 3)
    text = sampler.csv(sampler.select_rows(population))

    assert text.start_with?("﻿")
    table = CSV.parse(text.delete_prefix("﻿"), headers: true)
    assert_equal %w[case_no disease_category result year link], table.headers.first(5)
    assert_includes table.headers, "prior_career_list"
    assert_equal %w[labeler notes], table.headers.last(2)
    assert_equal 10, table.size
    assert(table.all? { |row| row["comorbidity_smoking"].nil? && row["labeler"].nil? })
  end

  test "DB에서 읽어 표본을 만든다" do
    3.times { |i| DiseaseCase.create!(case_no: "G-#{i}", disease_category: "musculoskeletal", result: "approved", year: 2022, link: "https://example.test/#{i}") }
    DiseaseCase.create!(case_no: "G-n", disease_category: nil, result: "rejected")
    selected = SolarExtraction::GoldSample.new(size: 3, seed: 5).select_rows
    assert_equal 3, selected.size
    assert_includes selected.map(&:case_no), "G-n"
  end
end
