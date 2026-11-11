# frozen_string_literal: true

require "test_helper"
require "tempfile"
require "rake"

class KscoCodePrunerTest < ActiveSupport::TestCase
  setup do
    DiseaseCaseKscoCode.delete_all
    KscoCode.delete_all
    %w[1111 1112 1113 1114].each { |code| KscoCode.create!(code: code, name: "분류 #{code}") }
    KscoCode.create!(code: "C1", name: "n")
    @a = DiseaseCase.create!(case_no: "KP-A", year: 2024)
    @b = DiseaseCase.create!(case_no: "KP-B", year: 2024)
    DiseaseCaseKscoCode.create!(disease_case: @a, ksco_code_id: "1111", similarity: 0.9)
    DiseaseCaseKscoCode.create!(disease_case: @a, ksco_code_id: "C1", similarity: 0.1)
    DiseaseCaseKscoCode.create!(disease_case: @b, ksco_code_id: "C1", similarity: 0.2)
  end

  teardown { @files&.each(&:close!) }

  def csv(*codes)
    file = Tempfile.new([ "ksco", ".csv" ])
    file.write(CSV.generate { |out| out << %w[코드 세분류]; codes.each { |c| out << [ c, "x" ] } })
    file.flush
    (@files ||= []) << file
    file.path
  end

  test "dry-run reports the extra code and its mappings without deleting" do
    result = KscoCodePruner.new(csv("1111", "1112", "1113", "1114", "1115")).call

    assert_not result.applied
    assert_equal 5, result.csv_codes
    assert_equal 5, result.db_codes
    assert_equal [ "1115" ], result.missing_in_db
    extra = result.extras.sole
    assert_equal [ "C1", "n", 2, 2 ], [ extra.code, extra.name, extra.mappings, extra.cases ]
    assert_equal 5, KscoCode.count
    assert_equal 3, DiseaseCaseKscoCode.count
  end

  test "apply deletes only the extra codes and their mappings" do
    result = KscoCodePruner.new(csv("1111", "1112", "1113", "1114"), apply: true).call

    assert result.applied
    assert_equal [ 2, 1 ], [ result.deleted_mappings, result.deleted_codes ]
    assert_equal %w[1111 1112 1113 1114], KscoCode.order(:code).pluck(:code)
    assert_equal [ "1111" ], DiseaseCaseKscoCode.pluck(:ksco_code_id)
    assert_equal 2, DiseaseCase.where(case_no: %w[KP-A KP-B]).count
  end

  test "refuses an empty csv and a csv that would delete most codes" do
    assert_raises(KscoCodePruner::Refused) { KscoCodePruner.new(csv).call }
    assert_raises(KscoCodePruner::Refused) { KscoCodePruner.new(csv("1111"), apply: true).call }
    assert_equal 5, KscoCode.count
  end

  test "rake task is dry-run by default and rejects an unknown mode" do
    Rake.application = Rake::Application.new
    Rake::Task.define_task(:environment)
    load Rails.root.join("lib/tasks/ksco_prune.rake")
    path = csv("1111", "1112", "1113", "1114")

    out = capture { Rake::Task["ksco:prune_codes"].invoke(path) }
    assert_includes out, "[dry-run]"
    assert_includes out, "C1 (\"n\") 매핑 2건 / 판정서 2건"
    assert_equal 5, KscoCode.count

    Rake::Task["ksco:prune_codes"].reenable
    assert_raises(SystemExit) { capture_err { Rake::Task["ksco:prune_codes"].invoke(path, "yes") } }

    Rake::Task["ksco:prune_codes"].reenable
    out = capture { Rake::Task["ksco:prune_codes"].invoke(path, "apply") }
    assert_includes out, "삭제: 매핑 2건, 코드 1개"
    assert_equal 4, KscoCode.count
  end

  private

  def capture
    old = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = old
  end

  def capture_err
    old = $stderr
    $stderr = StringIO.new
    yield
  ensure
    $stderr = old
  end
end
