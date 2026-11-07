namespace :normalize do
  desc "원본 컬럼을 정규화해 덮어쓴다 (먼저 CSV 백업: rails export:workercare_data). 기본은 dry-run, 적용은 rails 'normalize:disease_cases[apply]'"
  task :disease_cases, [ :mode ] => :environment do |_, args|
    apply = args[:mode] == "apply"
    normalizer = DiseaseCases::Normalizer
    puts apply ? "== 적용 모드 ==" : "== dry-run (DB 변경 없음) =="

    ActiveRecord::Base.transaction do
      %w[application_type work_type employment_type].each do |column|
        detail = "#{column}_detail"
        # detail이 이미 있는 행은 정규화가 끝난 행이다. 값이 같으면 건너뛰므로 여러 번 돌려도 같은 결과다.
        raw_counts = DiseaseCase.where(detail => nil).where.not(column => nil).group(column).count
        changed = 0
        raw_counts.each do |raw, n|
          result = normalizer.public_send(column, raw)
          next if result.value == raw && result.detail.nil?

          changed += n
          DiseaseCase.where(column => raw, detail => nil).update_all(column => result.value, detail => result.detail) if apply
        end
        puts format("%-22s 변경 대상 %d행 (고유값 %d종 중)", column, changed, raw_counts.size)
      end

      DiseaseCases::Normalizer::RULES.fetch("enums").each_key do |column|
        raw_counts = DiseaseCase.where.not(column => nil).group(column).count
        changed = 0
        raw_counts.each do |raw, n|
          value = normalizer.enum_value(column, raw)
          next if value == raw

          changed += n
          DiseaseCase.where(column => raw).update_all(column => value) if apply
        end
        puts format("%-22s 변경 대상 %d행 (빈값·허용값 밖 → NULL)", column, changed)
      end

      raise ActiveRecord::Rollback unless apply
    end

    Rails.cache.delete("disease_cases/application_type_options") if apply
    puts "완료"
  end

  desc "정규화 결과 미리보기 (DB 변경 없음). 사용법: rails 'normalize:report[application_type]' (application_type|work_type|employment_type)"
  task :report, [ :column, :limit ] => :environment do |_, args|
    column = args[:column].to_s
    unless %w[application_type work_type employment_type].include?(column)
      abort "컬럼은 application_type, work_type, employment_type 중 하나여야 합니다: #{column.inspect}"
    end
    limit = (args[:limit].presence || 25).to_i

    counts = DiseaseCase.group(column).count
    results = counts.map { |raw, n| [ raw, n, DiseaseCases::Normalizer.public_send(column, raw) ] }

    by_value = Hash.new(0)
    results.each { |_, n, r| by_value[r.value] += n }
    with_detail = results.sum { |_, n, r| r.detail ? n : 0 }
    other = DiseaseCases::Normalizer::RULES.dig(column, "other")

    puts "== #{column}"
    puts "변경 전 distinct=#{counts.size} → 변경 후 distinct=#{by_value.size}, detail 보존 행=#{with_detail}"
    puts "-- 결과값별 건수"
    by_value.sort_by { |_, n| -n }.first(limit).each { |v, n| puts format("  %-28s %7d", v.inspect, n) }
    puts "-- 기타로 분류된 원문 상위 #{limit}"
    results.select { |_, _, r| r.value == other }.sort_by { |_, n, _| -n }.first(limit)
      .each { |raw, n, _| puts format("  %7d  %s", n, raw.inspect) }
    puts "-- detail이 붙는 변환 예 상위 #{limit}"
    results.select { |_, _, r| r.detail && r.value != other }.sort_by { |_, n, _| -n }.first(limit)
      .each { |raw, n, r| puts format("  %7d  %s → %s / %s", n, raw.inspect, r.value.inspect, r.detail.inspect) }
  end
end
