# frozen_string_literal: true

require "csv"
require "digest"
require "fileutils"
require "json"
require "open3"
require "zlib"

module Exports
  # 판정서·KSCO 데이터를 분석·공유용 CSV 스냅샷으로 내보낸다. 복구용 백업이 아니다(복구용은 Exports::SqliteBackup).
  #
  # - 기본은 판정서 본문 8개 컬럼을 뺀다(full_text: true 로 포함).
  # - 모든 읽기는 한 읽기 트랜잭션 안에서 해 파일 사이의 건수가 서로 맞는다.
  # - *.tmp 에 쓰고 검증한 뒤 이름을 바꾼다. 쓰는 중 만든 행 수와 다시 읽은 행 수를 DB 건수와 대조하고 어긋나면 중단한다.
  # - manifest_<날짜>.json 에 스키마 버전·모드·파일별 행 수·컬럼·바이트·SHA-256을 남긴다.
  class WorkercareData
    class Error < StandardError; end

    TEXT_COLUMNS = %w[
      statement claim_purpose application_content applicant_claim
      medical_records recognized_facts related_laws committee_decision
    ].freeze

    BOM = "﻿"

    Report = Struct.new(:planned, :manifest, :written, :warnings, :dry_run, keyword_init: true)

    def self.default_out_dir
      Rails.root.join("storage", "exports")
    end

    def initialize(date: nil, out_dir: nil, full_text: false, excel: false, gzip: false, force: false, dry_run: false)
      @date = (date.presence || Date.current.strftime("%Y%m%d")).to_s
      unless @date.match?(/\A\d{8}\z/) && Date.valid_date?(@date[0, 4].to_i, @date[4, 2].to_i, @date[6, 2].to_i)
        raise Error, "날짜는 유효한 YYYYMMDD 형식이어야 합니다: #{@date}"
      end

      @out_dir = Pathname(out_dir.presence || self.class.default_out_dir)
      @full_text = full_text
      @excel = excel
      @gzip = gzip
      @force = force
      @dry_run = dry_run
    end

    attr_reader :date, :out_dir

    def run
      report = nil
      ActiveRecord::Base.transaction do
        plan = build_plan
        report = @dry_run ? Report.new(planned: plan[:files], warnings: plan[:warnings], dry_run: true) : write_all(plan)
      end
      report
    end

    private

    def csv_ext
      @gzip ? "csv.gz" : "csv"
    end

    def dictionary_path
      @out_dir.join("workercare_data_dictionary_#{@date}.md")
    end

    def manifest_path
      @out_dir.join("manifest_#{@date}.json")
    end

    def disease_case_columns
      @full_text ? DiseaseCase.column_names : DiseaseCase.column_names - TEXT_COLUMNS
    end

    def excluded_columns
      @full_text ? [] : TEXT_COLUMNS & DiseaseCase.column_names
    end

    # 읽기 트랜잭션 안에서 건수를 먼저 잡고 계획을 만든다.
    def build_plan
      counts = {
        disease_cases: DiseaseCase.count,
        ksco_codes: KscoCode.count,
        disease_case_ksco_codes: DiseaseCaseKscoCode.count
      }
      ksco_available = counts[:ksco_codes].positive? && counts[:disease_case_ksco_codes].positive?
      files = [
        { name: :disease_cases, table: "disease_cases", model: DiseaseCase, columns: disease_case_columns, rows: counts[:disease_cases] }
      ]
      warnings = []
      if ksco_available
        files << { name: :ksco_codes, table: "ksco_codes", model: KscoCode, columns: KscoCode.column_names, rows: counts[:ksco_codes] }
        files << { name: :disease_case_ksco_codes, table: "disease_case_ksco_codes", model: DiseaseCaseKscoCode,
                   columns: DiseaseCaseKscoCode.column_names, rows: counts[:disease_case_ksco_codes] }
      else
        warnings << "KSCO 테이블이 비어 있어 ksco_codes·disease_case_ksco_codes CSV를 만들지 않습니다 " \
                    "(ksco_codes=#{counts[:ksco_codes]}건, disease_case_ksco_codes=#{counts[:disease_case_ksco_codes]}건). import:ksco_codes·import:ksco_mappings 적재 여부를 확인하세요."
      end
      files.each { |file| file[:path] = @out_dir.join("#{file[:name]}_#{@date}.#{csv_ext}") }
      { files: files, counts: counts, ksco_available: ksco_available, warnings: warnings }
    end

    def write_all(plan)
      refuse_overwrite!(plan[:files].map { |file| file[:path] } + [ dictionary_path, manifest_path ])
      FileUtils.mkdir_p(@out_dir)

      tmp_paths = []
      written = []
      begin
        plan[:files].each do |file|
          tmp = tmp_path(file[:path])
          tmp_paths << tmp
          written << write_csv(file, tmp)
        end
        dictionary_tmp = tmp_path(dictionary_path)
        tmp_paths << dictionary_tmp
        File.binwrite(dictionary_tmp, dictionary(plan).to_s)
        dictionary_entry = file_entry(dictionary_path, dictionary_tmp, kind: "dictionary")

        manifest = build_manifest(plan, written, dictionary_entry)
        manifest_tmp = tmp_path(manifest_path)
        tmp_paths << manifest_tmp
        File.binwrite(manifest_tmp, JSON.pretty_generate(manifest) + "\n")

        # 모두 검증됐을 때만 이름을 바꾼다. manifest 가 마지막이다.
        (plan[:files].map { |file| file[:path] } + [ dictionary_path, manifest_path ]).each do |final|
          File.rename(tmp_path(final), final)
        end
      ensure
        tmp_paths.each { |tmp| FileUtils.rm_f(tmp) }
      end
      Report.new(planned: plan[:files], manifest: manifest, written: written + [ dictionary_entry ], warnings: plan[:warnings], dry_run: false)
    end

    def tmp_path(path)
      Pathname("#{path}.tmp")
    end

    def refuse_overwrite!(paths)
      return if @force

      existing = paths.select(&:exist?)
      return if existing.empty?

      raise Error, "같은 날짜의 파일이 이미 있어 덮어쓰지 않습니다(덮어쓰려면 FORCE=1): #{existing.map(&:basename).join(', ')}"
    end

    def write_csv(file, tmp)
      columns = file[:columns]
      written_rows = 0
      File.open(tmp, "wb") do |raw|
        io = @gzip ? Zlib::GzipWriter.new(raw) : raw
        io.write(BOM) if @excel
        csv = CSV.new(io, write_headers: true, headers: columns, encoding: "UTF-8")
        file[:model].find_each(batch_size: 1_000) do |record|
          csv << columns.map { |column| record.public_send(column) }
          written_rows += 1
        end
        io.close if @gzip # GzipWriter#close 는 raw 도 닫는다
      end

      verify_rows!(file, written_rows, count_rows(tmp))
      file_entry(file[:path], tmp, kind: "csv", file: file, rows: written_rows)
    end

    def verify_rows!(file, written_rows, reread_rows)
      return if written_rows == file[:rows] && reread_rows == file[:rows]

      raise Error, "#{file[:table]} 행 수가 맞지 않아 중단합니다: DB=#{file[:rows]}, 쓴 행=#{written_rows}, 다시 읽은 행=#{reread_rows}"
    end

    # 만든 파일을 처음부터 다시 읽어 데이터 행을 센다(헤더 제외).
    def count_rows(path)
      reader = @gzip ? Zlib::GzipReader.open(path.to_s) : File.open(path, "rb")
      begin
        count = 0
        CSV.new(reader, headers: true, encoding: "UTF-8").each { count += 1 }
        count
      ensure
        reader.close
      end
    end

    def file_entry(final_path, tmp, kind:, file: nil, rows: nil)
      entry = {
        name: final_path.basename.to_s,
        kind: kind,
        bytes: tmp.size,
        sha256: Digest::SHA256.file(tmp).hexdigest
      }
      if file
        entry[:table] = file[:table]
        entry[:rows] = rows
        entry[:columns] = file[:columns]
      end
      entry
    end

    def build_manifest(plan, written, dictionary_entry)
      {
        export_date: @date,
        generated_at: Time.current.iso8601,
        rails_env: Rails.env,
        schema_version: ActiveRecord::Base.connection.select_values("SELECT version FROM schema_migrations").map(&:to_i).max.to_s,
        git_sha: git_sha,
        mode: {
          full_text: @full_text,
          excel_bom: @excel,
          gzip: @gzip,
          excluded_columns: excluded_columns
        },
        ksco_empty: !plan[:ksco_available],
        warnings: plan[:warnings],
        row_verification: "쓰는 중 센 행 수와 완성 파일을 다시 읽어 센 행 수가 같은 읽기 트랜잭션의 DB 건수와 일치함",
        files: written + [ dictionary_entry ]
      }
    end

    def git_sha
      ENV["GIT_SHA"].presence || ENV["KAMAL_VERSION"].presence || begin
        out, status = Open3.capture2("git", "rev-parse", "HEAD", chdir: Rails.root.to_s, err: File::NULL)
        status.success? ? out.strip.presence : nil
      end
    rescue SystemCallError
      nil
    end

    def command_line
      flags = []
      flags << "FULL_TEXT=1" if @full_text
      flags << "EXCEL=1" if @excel
      flags << "GZIP=1" if @gzip
      (flags + [ "bin/rails", "export:workercare_data[#{@date}]" ]).join(" ")
    end

    def dictionary(plan)
      by_name = plan[:files].index_by { |file| file[:name] }
      Dictionary.new(
        export_date: @date,
        files: plan[:files].to_h { |file| [ file[:name], file[:path] ] },
        columns: {
          disease_cases: disease_case_columns,
          ksco_codes: KscoCode.column_names,
          disease_case_ksco_codes: DiseaseCaseKscoCode.column_names
        },
        ksco_available: plan[:ksco_available] && by_name.key?(:ksco_codes),
        full_text: @full_text,
        excel: @excel,
        gzip: @gzip,
        command: command_line,
        excluded_columns: excluded_columns
      )
    end
  end
end
