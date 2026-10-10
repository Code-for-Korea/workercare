namespace :import do
  desc "KSCO(한국표준직업분류) 코드 CSV 임포트\n" \
       "  사용법: rails 'import:ksco_codes[wip/ksco-level-4-details.csv]'"
  task :ksco_codes, [:path] => :environment do |_, args|
    require "csv"
    path = args[:path] or abort "CSV 경로를 지정하세요."
    raise "파일 없음: #{path}" unless File.exist?(path)

    imported = 0
    CSV.foreach(path, headers: true, encoding: "UTF-8") do |row|
      KscoCode.find_or_initialize_by(code: row["코드"].to_s.strip).update!(
        name: row["세분류"].to_s.strip,
        minor: row["소분류"].to_s.strip,
        submajor: row["중분류"].to_s.strip,
        major: row["대분류"].to_s.strip,
        job_examples: row["직업예시"].to_s.strip,
        exclusions: row["직업제외"].to_s.strip
      )
      imported += 1
    end
    puts "KSCO 임포트 완료: #{imported}건"
  end
end
