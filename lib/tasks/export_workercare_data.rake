# frozen_string_literal: true

namespace :export do
  desc <<~DESC.squish
    판정서·KSCO 데이터를 분석·공유용 CSV 스냅숏으로 내보내고 데이터 사전과 manifest를 만든다(복구용 백업이 아니다. 복구용은 db:backup).
    사용법: rails 'export:workercare_data[YYYYMMDD]'.
    환경변수: OUT_DIR(기본 storage/exports), FULL_TEXT=1(판정서 본문 8개 컬럼 포함, 기본은 제외), EXCEL=1(UTF-8 BOM),
    GZIP=1(.csv.gz), FORCE=1(같은 날짜 파일 덮어쓰기), DRY_RUN=1(쓰지 않고 계획과 건수만 출력).
  DESC
  task :workercare_data, [ :date ] => :environment do |_, args|
    truthy = ->(name) { %w[1 true yes].include?(ENV[name].to_s.downcase) }
    exporter = Exports::WorkercareData.new(
      date: args[:date], out_dir: ENV["OUT_DIR"],
      full_text: truthy.("FULL_TEXT"), excel: truthy.("EXCEL"), gzip: truthy.("GZIP"),
      force: truthy.("FORCE"), dry_run: truthy.("DRY_RUN")
    )
    report = exporter.run

    puts(report.dry_run ? "DRY_RUN: 아무것도 쓰지 않았습니다. 계획(#{exporter.date}):" : "추출 완료 (#{exporter.date})")
    puts "출력 디렉터리: #{exporter.out_dir}"
    if report.dry_run
      report.planned.each do |file|
        puts "- #{file[:path].basename}: #{file[:rows].to_fs(:delimited)}행, 컬럼 #{file[:columns].size}개"
      end
    else
      report.written.each do |entry|
        rows = entry[:rows] ? "#{entry[:rows].to_fs(:delimited)}행, " : ""
        puts "- #{entry[:name]}: #{rows}#{ActiveSupport::NumberHelper.number_to_human_size(entry[:bytes])}, sha256=#{entry[:sha256][0, 12]}…"
      end
      puts "- manifest_#{exporter.date}.json"
      puts "모드: 본문 #{report.manifest[:mode][:full_text] ? '포함 (외부 공유 금지)' : '제외'}, BOM #{report.manifest[:mode][:excel_bom]}, gzip #{report.manifest[:mode][:gzip]}"
    end
    report.warnings.each { |warning| warn "경고: #{warning}" }
  rescue Exports::WorkercareData::Error => e
    abort "내보내기 실패: #{e.message}"
  end
end
