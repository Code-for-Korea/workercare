# frozen_string_literal: true

require "test_helper"
require "tempfile"

class DiseaseCases::KscoMappingImporterTest < ActiveSupport::TestCase
  Importer = DiseaseCases::KscoMappingImporter

  setup do
    DiseaseCaseKscoCode.delete_all
    %w[9222 9221 8001].each { |code| KscoCode.find_or_create_by!(code: code) { |k| k.name = "시험 #{code}" } }
    @a = DiseaseCase.create!(case_no: "KM-A", year: 2024, job_name: "원래 직종")
    @b = DiseaseCase.create!(case_no: "KM-B", year: 2024)
  end

  def csv(*rows)
    file = Tempfile.new([ "ksco", ".csv" ])
    file.write(CSV.generate { |out| out << %w[case_no 직종명 ksco_codes_json]; rows.each { |r| out << r } })
    file.flush
    (@files ||= []) << file
    file.path
  end

  def json(*pairs) = pairs.map { |code, sim| { "ksco_code" => code, "name" => "x", "similarity" => sim } }.to_json

  def run_import(path, apply: true) = Importer.new(path, apply: apply).tap(&:call).result

  def mappings(disease_case) = disease_case.disease_case_ksco_codes.order(:ksco_code_id).pluck(:ksco_code_id, :similarity)

  test "dry-run counts but writes nothing" do
    result = run_import(csv([ "KM-A", "x", json([ "9222", 0.9 ], [ "9221", 0.8 ]) ]), apply: false)

    assert_equal 2, result.inserted
    assert_equal 0, DiseaseCaseKscoCode.count
  end

  test "apply inserts, updates a changed similarity and deletes codes missing from the list" do
    DiseaseCaseKscoCode.create!(disease_case: @a, ksco_code_id: "9222", similarity: 0.1)
    DiseaseCaseKscoCode.create!(disease_case: @a, ksco_code_id: "8001", similarity: 0.5)

    result = run_import(csv([ "KM-A", "x", json([ "9222", 0.9 ], [ "9221", 0.8 ]) ]))

    assert_equal [ 1, 1, 1 ], [ result.inserted, result.updated, result.deleted ]
    assert_equal [ [ "9221", 0.8 ], [ "9222", 0.9 ] ], mappings(@a)
  end

  test "running twice changes nothing the second time" do
    path = csv([ "KM-A", "x", json([ "9222", 0.9 ]) ])
    run_import(path)
    again = run_import(path)

    assert_equal [ 0, 0, 0, 1 ], [ again.inserted, again.updated, again.deleted, again.unchanged ]
  end

  test "blank and broken json keep the existing mappings" do
    DiseaseCaseKscoCode.create!(disease_case: @a, ksco_code_id: "9222", similarity: 0.5)
    DiseaseCaseKscoCode.create!(disease_case: @b, ksco_code_id: "9221", similarity: 0.5)

    result = run_import(csv([ "KM-A", "x", "" ], [ "KM-B", "x", "{깨진" ]))

    assert_equal [ 1, 1 ], [ result.preserved_blank, result.preserved_broken ]
    assert_equal 0, result.deleted
    assert_equal 1, @a.disease_case_ksco_codes.count
    assert_equal 1, @b.disease_case_ksco_codes.count
  end

  test "an empty array is a real target and clears the mappings" do
    DiseaseCaseKscoCode.create!(disease_case: @a, ksco_code_id: "9222", similarity: 0.5)
    run_import(csv([ "KM-A", "x", "[]" ]))

    assert_empty mappings(@a)
  end

  test "codes missing from ksco_codes are skipped but still count as listed, so nothing is deleted for them" do
    DiseaseCaseKscoCode.create!(disease_case: @a, ksco_code_id: "9222", similarity: 0.5)
    KscoCode.where(code: "9222").delete_all

    result = run_import(csv([ "KM-A", "x", json([ "9222", 0.9 ], [ "0000", 0.8 ]) ]))

    assert_equal({ "0000" => 1 }, result.unknown_codes.slice("0000"))
    assert_equal 0, result.deleted
    assert_equal 1, @a.disease_case_ksco_codes.where(ksco_code_id: "9222").count
  end

  test "the last row wins for a repeated case_no and the larger similarity wins for a repeated code" do
    result = run_import(csv(
      [ "KM-A", "x", json([ "9222", 0.9 ]) ],
      [ "KM-A", "x", json([ "9221", 0.4 ], [ "9221", 0.7 ]) ]
    ))

    assert_equal 1, result.duplicate_case_rows
    assert_equal [ [ "9221", 0.7 ] ], mappings(@a)
  end

  test "unknown case numbers are counted and the import does not touch extracted columns" do
    result = run_import(csv([ "KM-NONE", "x", json([ "9222", 0.9 ]) ], [ "KM-A", "바뀌면 안 됨", json([ "9222", 0.9 ]) ]))

    assert_equal 1, result.unknown_cases
    assert_equal "원래 직종", @a.reload.job_name
  end
end
