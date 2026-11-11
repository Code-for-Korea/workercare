namespace :ksco do
  desc "CSV에 없는 ksco_codes 행과 그 매핑(disease_case_ksco_codes)을 지운다. 기본은 dry-run.\n" \
       "  사용법: rails 'ksco:prune_codes[wip/ksco-level-4-details.csv]'        (미리보기)\n" \
       "          rails 'ksco:prune_codes[wip/ksco-level-4-details.csv,apply]'  (삭제)\n" \
       "  CSV의 코드를 정본으로 본다. 판정서와 CSV에 있는 코드의 매핑은 건드리지 않는다. 운영 DB는 백업 뒤 사용자가 직접 실행한다."
  task :prune_codes, [ :csv, :mode ] => :environment do |_, args|
    path = args[:csv] or abort "CSV 경로를 지정하세요."
    abort "파일 없음: #{path}" unless File.exist?(path)
    abort "mode는 비우거나 apply만 허용합니다: #{args[:mode].inspect}" unless [ nil, "", "apply" ].include?(args[:mode])

    begin
      result = KscoCodePruner.new(path, apply: args[:mode] == "apply").call
    rescue KscoCodePruner::Refused => e
      abort e.message
    end

    puts(result.applied ? "[삭제] ksco_codes를 바꿨습니다." : "[dry-run] 아무것도 지우지 않았습니다. 지우려면 두 번째 인자로 apply를 주세요.")
    puts "CSV 코드 #{result.csv_codes}개 / DB 코드 #{result.db_codes}개 / CSV에만 있는 코드 #{result.missing_in_db.size}개"
    if result.extras.empty?
      puts "CSV에 없는 DB 코드: 없음"
    else
      puts "CSV에 없는 DB 코드 #{result.extras.size}개:"
      result.extras.each { |e| puts "  #{e.code} (#{e.name.inspect}) 매핑 #{e.mappings}건 / 판정서 #{e.cases}건" }
    end
    puts "삭제: 매핑 #{result.deleted_mappings}건, 코드 #{result.deleted_codes}개" if result.applied
  end
end
