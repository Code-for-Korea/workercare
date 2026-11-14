namespace :self_care_summaries do
  # 버튼으로 고를 수 있는 조건(신체부위 × 직종, 판정 결과는 "모두 보기") 중 판정서가 많은 순서로 N개의 요약을 미리 만든다.
  # 판정 결과를 고른 조합과 조건 완화가 걸리는 조합은 첫 방문자가 열 때 만들어진다(주문형).
  desc "신체부위가 있는 많이 찾는 조건 조합 N개의 쉬운 요약을 EXAONE으로 미리 만든다(ANY_BODY=1이면 직종만 있는 조합도). DRY_RUN=1이면 조합만 출력. 하루 요청 예산(EXAONE_DAILY_REQUEST_CAP, 기본 28800)에서 멈춘다. 문서: docs/self-care-form.md"
  task :warm, [ :limit ] => :environment do |_, args|
    limit = Integer(args[:limit] || 50)
    dry = ENV["DRY_RUN"].present?
    generator_class = SelfCareForm::SummaryGenerator
    abort "EXAONE_API_KEY가 없습니다(.env 또는 환경 변수)." if !dry && generator_class.api_key.blank?

    combos = SelfCareSummaries::Warm.combinations(limit, require_body: ENV["ANY_BODY"].blank?)
    budget = SelfCareForm::ExaoneBudget
    puts "오늘 EXAONE 요청: #{budget.used}/#{budget.cap}회 사용(헤더가 알려 준 남은 횟수: #{budget.remaining_hint.inspect}). 한도에 이르면 멈춥니다."
    seconds_each = SelfCareSummaries::Warm::ESTIMATED_SECONDS_EACH
    puts "조합 #{combos.size}개(요청 한도 초당 1회, 건당 약 #{seconds_each}초로 어림 → 약 #{(combos.size * seconds_each / 60.0).ceil}분)"
    combos.each_with_index do |combo, index|
      puts format("%3d. %-12s %-14s %6s건", index + 1, combo.key.body_concept.presence || "(신체부위 없음)",
        combo.key.job.presence || "(직종 없음)", combo.facts.capped ? "500+" : combo.facts.total_count)
    end
    next puts("DRY_RUN: 아무것도 만들지 않았습니다.") if dry

    generator = generator_class.new
    done = 0
    combos.each_with_index do |combo, index|
      unless budget.available?
        puts "오늘 요청 한도에 이르러 멈춥니다(#{budget.used}/#{budget.cap}). 내일 같은 명령으로 이어 받으세요."
        break
      end

      row, = SelfCareSummary.claim(combo.key, combo.facts.digest)
      if row.ready?
        puts "#{index + 1}/#{combos.size} 이미 있음(건너뜀)"
        next
      end

      row.update!(status: "pending", error_message: nil) if row.failed?
      started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      generator.generate(row)
      done += 1
      seconds = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - started).round(1)
      puts "#{index + 1}/#{combos.size} #{row.reload.status} #{seconds}초#{" (#{row.error_message})" if row.failed?}"
    end
    puts "끝: #{done}건을 처리했습니다. 이어서 하려면 같은 명령을 다시 실행하세요(이미 만든 조합은 건너뜁니다)."
  end
end
