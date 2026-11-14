namespace :import do
  desc "추출 CSV의 KSCO 후보(ksco_codes_json)를 disease_case_ksco_codes에 반영한다. 기본은 dry-run.\n" \
       "  사용법: rails 'import:ksco_mappings[wip/extract_disease_cases_details_cerebras-ksco.csv]'        (미리보기)\n" \
       "          rails 'import:ksco_mappings[wip/extract_disease_cases_details_cerebras-ksco.csv,apply]'  (반영)\n" \
       "  먼저 import:ksco_codes를 실행해 ksco_codes 테이블을 채워 두세요. 추출 컬럼·FTS는 건드리지 않습니다."
  task :ksco_mappings, [ :path, :mode ] => :environment do |_, args|
    path = args[:path] or abort "CSV 경로를 지정하세요."
    abort "파일 없음: #{path}" unless File.exist?(path)
    abort "mode는 비우거나 apply만 허용합니다: #{args[:mode].inspect}" unless [ nil, "", "apply" ].include?(args[:mode])
    abort "ksco_codes가 비어 있습니다. 먼저 import:ksco_codes를 실행하세요." unless KscoCode.exists?

    apply = args[:mode] == "apply"
    importer = DiseaseCases::KscoMappingImporter.new(path, apply: apply, logger: Rails.logger)
    result = importer.call

    puts(apply ? "[반영] 매핑 테이블을 바꿨습니다." : "[dry-run] 아무것도 쓰지 않았습니다. 반영하려면 두 번째 인자로 apply를 주세요.")
    puts "CSV 행: #{result.rows} / 대상 판정서: #{result.cases} (판정서 없음 #{result.unknown_cases}, 같은 case_no 중복 행 #{result.duplicate_case_rows})"
    puts "추가 #{result.inserted} / 유사도 변경 #{result.updated} / 삭제 #{result.deleted} / 그대로 #{result.unchanged}"
    puts "기존 매핑 유지: 빈 JSON #{result.preserved_blank}행, 깨진 JSON #{result.preserved_broken}행"
    if result.unknown_codes.any?
      puts "ksco_codes에 없는 코드 #{result.unknown_codes.size}종(#{result.unknown_codes.values.sum}회): " \
           "#{result.unknown_codes.sort_by { |_, n| -n }.first(10).map { |c, n| "#{c}(#{n})" }.join(', ')}"
    end
  end
end
