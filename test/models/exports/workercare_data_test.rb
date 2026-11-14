# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "zlib"

class Exports::WorkercareDataTest < ActiveSupport::TestCase
  setup do
    @dir = Dir.mktmpdir("export-test")
    DiseaseCase.create!(case_no: "EXP-1", disease_name: "요통", result: "approved", year: 2024,
      statement: "본문 하나, \"쉼표\"와\n줄바꿈", committee_decision: "결정 본문", job_name: "용접공")
    DiseaseCase.create!(case_no: "EXP-2", disease_name: "난청", result: "rejected", year: 2023, statement: "본문 둘")
  end

  teardown { FileUtils.remove_entry(@dir) }

  def export(**options)
    Exports::WorkercareData.new(date: "20261112", out_dir: @dir, **options)
  end

  def csv_rows(name, gzip: false)
    path = File.join(@dir, name)
    data = gzip ? Zlib::GzipReader.open(path, &:read) : File.binread(path)
    data.force_encoding("UTF-8")
    CSV.parse(data.delete_prefix("﻿"), headers: true)
  end

  def seed_ksco
    ksco = KscoCode.create!(code: "7432", name: "용접원")
    DiseaseCaseKscoCode.create!(disease_case: DiseaseCase.first, ksco_code: ksco, similarity: 0.9)
  end

  test "기본은 본문 8개 컬럼을 뺀다" do
    export.run
    headers = csv_rows("disease_cases_20261112.csv").headers

    assert_empty headers & Exports::WorkercareData::TEXT_COLUMNS
    assert_includes headers, "case_no"
    assert_includes headers, "job_name"
    assert_equal 2, csv_rows("disease_cases_20261112.csv").size
    assert_no_match(/본문 하나/, File.read(File.join(@dir, "disease_cases_20261112.csv")))
  end

  test "TEXT_COLUMNS는 실제 스키마의 컬럼이다" do
    assert_empty Exports::WorkercareData::TEXT_COLUMNS - DiseaseCase.column_names
  end

  test "FULL_TEXT는 본문 컬럼을 포함하고 줄바꿈·따옴표를 보존한다" do
    export(full_text: true).run
    rows = csv_rows("disease_cases_20261112.csv")

    assert_equal Exports::WorkercareData::TEXT_COLUMNS, rows.headers & Exports::WorkercareData::TEXT_COLUMNS
    assert_equal "본문 하나, \"쉼표\"와\n줄바꿈", rows.find { |row| row["case_no"] == "EXP-1" }["statement"]
  end

  test "EXCEL은 UTF-8 BOM을 붙이고 기본은 붙이지 않는다" do
    export(excel: true).run
    assert_equal "\xEF\xBB\xBF".b, File.binread(File.join(@dir, "disease_cases_20261112.csv"), 3)

    other = Dir.mktmpdir("export-test2")
    Exports::WorkercareData.new(date: "20261112", out_dir: other).run
    assert_not_equal "\xEF\xBB\xBF".b, File.binread(File.join(other, "disease_cases_20261112.csv"), 3)
  ensure
    FileUtils.remove_entry(other) if other
  end

  test "GZIP은 읽을 수 있는 .csv.gz를 만든다" do
    export(gzip: true, excel: true).run

    assert_not File.exist?(File.join(@dir, "disease_cases_20261112.csv"))
    assert_equal %w[EXP-1 EXP-2], csv_rows("disease_cases_20261112.csv.gz", gzip: true).map { |row| row["case_no"] }.sort
  end

  test "manifest의 건수와 sha256이 파일과 맞는다" do
    seed_ksco
    report = export(gzip: true).run
    manifest = JSON.parse(File.read(File.join(@dir, "manifest_20261112.json")))

    assert_equal report.manifest.deep_stringify_keys["files"].size, manifest["files"].size
    assert_equal ActiveRecord::Base.connection.select_values("SELECT version FROM schema_migrations").map(&:to_i).max.to_s, manifest["schema_version"]
    assert_equal({ "full_text" => false, "excel_bom" => false, "gzip" => true, "excluded_columns" => Exports::WorkercareData::TEXT_COLUMNS }, manifest["mode"])
    assert_equal false, manifest["ksco_empty"]

    csv_entries = manifest["files"].select { |file| file["kind"] == "csv" }
    assert_equal %w[disease_case_ksco_codes disease_cases ksco_codes], csv_entries.map { |file| file["table"] }.sort
    manifest["files"].each do |entry|
      path = File.join(@dir, entry["name"])
      assert_equal File.size(path), entry["bytes"]
      assert_equal Digest::SHA256.file(path).hexdigest, entry["sha256"]
    end
    cases = csv_entries.find { |file| file["table"] == "disease_cases" }
    assert_equal DiseaseCase.count, cases["rows"]
    assert_equal DiseaseCase.column_names - Exports::WorkercareData::TEXT_COLUMNS, cases["columns"]
  end

  test "데이터 사전과 manifest에 모드가 기록된다" do
    export.run
    dictionary = File.read(File.join(@dir, "workercare_data_dictionary_20261112.md"))
    assert_match(/본문 제외\(기본\)/, dictionary)
    assert_match(/DB 복구용 백업이 아니다/, dictionary)
    assert_no_match(/\| `statement` \|/, dictionary)

    other = Dir.mktmpdir("export-test2")
    Exports::WorkercareData.new(date: "20261112", out_dir: other, full_text: true).run
    full = File.read(File.join(other, "workercare_data_dictionary_20261112.md"))
    assert_match(/본문 포함\(FULL_TEXT=1\)/, full)
    assert_match(/외부에 공유하지 않는다/, full)
    assert_match(/\| `statement` \|/, full)
  ensure
    FileUtils.remove_entry(other) if other
  end

  test "같은 날짜 파일이 있으면 FORCE 없이는 거부하고 파일을 건드리지 않는다" do
    export.run
    path = File.join(@dir, "disease_cases_20261112.csv")
    before = Digest::SHA256.file(path).hexdigest
    DiseaseCase.create!(case_no: "EXP-3", disease_name: "추가", year: 2022)

    assert_raises(Exports::WorkercareData::Error) { export.run }
    assert_equal before, Digest::SHA256.file(path).hexdigest

    export(force: true).run
    assert_equal 3, csv_rows("disease_cases_20261112.csv").size
    assert_empty Dir[File.join(@dir, "*.tmp")]
  end

  test "DRY_RUN은 아무것도 쓰지 않고 계획과 건수를 돌려준다" do
    empty_dir = File.join(@dir, "not-created")
    report = Exports::WorkercareData.new(date: "20261112", out_dir: empty_dir, dry_run: true).run

    assert report.dry_run
    assert_equal [ "disease_cases" ], report.planned.map { |file| file[:table] }
    assert_equal 2, report.planned.first[:rows]
    assert_not File.exist?(empty_dir)
  end

  test "KSCO 테이블이 비어 있으면 경고하고 manifest에 표시한다" do
    report = export.run
    manifest = JSON.parse(File.read(File.join(@dir, "manifest_20261112.json")))

    assert manifest["ksco_empty"]
    assert_match(/KSCO 테이블이 비어 있어/, report.warnings.first)
    assert_equal manifest["warnings"], report.warnings
    assert_not File.exist?(File.join(@dir, "ksco_codes_20261112.csv"))
  end

  test "유효하지 않은 날짜는 거부한다" do
    assert_raises(Exports::WorkercareData::Error) { Exports::WorkercareData.new(date: "20261340", out_dir: @dir) }
  end

  test "행 수가 DB와 어긋나면 중단하고 최종 파일을 남기지 않는다" do
    exporter = export
    exporter.define_singleton_method(:verify_rows!) { |file, written, _reread| super(file, written, written + 1) }

    assert_raises(Exports::WorkercareData::Error) { exporter.run }
    assert_empty Dir[File.join(@dir, "*")]
  end
end
