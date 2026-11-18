# frozen_string_literal: true

# Solar LLM 추가 추출(docs/solar-extraction-plan.md). DB에는 쓰지 않고 storage/exports/solar/ 아래 JSONL로 둔다.
#
#   bin/rails "solar:extract[comorbidity]" LIMIT=20           # dry-run(기본): 호출 없음, 추정만
#   APPLY=1 bin/rails "solar:extract[comorbidity]" LIMIT=200 CONCURRENCY=2   # 실제 호출(UPSTAGE_API_KEY 필요)
#   bin/rails "solar:gold_sample[200]"                          # 정답 표본 CSV
#
# 환경변수: LIMIT, SCOPE(all | empty_rows | disease_category=근골격계 | case_nos=파일), CONCURRENCY(1~8), MODEL(기본 SOLAR_MODEL 또는 solar-mini4),
#   RPM(100), TPM(250000), OUT_DIR, APPLY=1, SKIP_FAILED=1, PROGRESS_EVERY(50),
#   추정: TOKENS_PER_CHAR(0.6), OUT_TOKENS(300), PRICE_IN(0.10), PRICE_OUT(0.40), LATENCY(4.0초)
namespace :solar do
  desc "Solar로 판정서에서 과제(comorbidity | prior_career)를 추출한다. 기본은 dry-run, APPLY=1이면 호출"
  task :extract, [ :task ] => :environment do |_, args|
    task = SolarExtraction::Tasks.fetch(args[:task].presence || abort("과제 이름이 필요합니다: solar:extract[#{SolarExtraction::Tasks.names.join('|')}]"))
    apply = ENV["APPLY"] == "1"
    options = SolarExtraction::Estimator.options_from_env
    concurrency = Integer(ENV["CONCURRENCY"].presence || 1)
    limiter = SolarExtraction::RateLimiter.from_env
    out_dir = ENV["OUT_DIR"].presence || Rails.root.join("storage/exports/solar", task.name)

    client = nil
    if apply
      begin
        client = SolarExtraction::Client.new(model: ENV["MODEL"], limiter: limiter)
      rescue SolarExtraction::MissingApiKey => e
        abort e.message
      end
    end

    estimator = SolarExtraction::Estimator.new(**options, rpm: limiter.rpm, tpm: limiter.tpm, concurrency: concurrency.clamp(1, SolarExtraction::Runner::MAX_CONCURRENCY))
    runner = SolarExtraction::Runner.new(
      task: task, out_dir: out_dir, scope: ENV["SCOPE"], limit: ENV["LIMIT"].presence && Integer(ENV["LIMIT"]),
      concurrency: concurrency, apply: apply, client: client, estimator: estimator, skip_failed: ENV["SKIP_FAILED"] == "1",
      progress_every: Integer(ENV["PROGRESS_EVERY"].presence || 50),
      price_in_per_m: options[:price_in_per_m], price_out_per_m: options[:price_out_per_m]
    )
    begin
      runner.run
    rescue SolarExtraction::Runner::Locked => e
      abort "[solar] #{e.message}"
    end
  end

  desc "정답(gold) 표본 CSV를 만든다. disease_category × result 층화, SEED(기본 20261118). 본문·LLM 없음"
  task :gold_sample, [ :size ] => :environment do |_, args|
    size = Integer(args[:size].presence || 200)
    seed = Integer(ENV["SEED"].presence || SolarExtraction::GoldSample::DEFAULT_SEED)
    sampler = SolarExtraction::GoldSample.new(size: size, seed: seed)
    rows = DiseaseCase.order(:case_no).pluck(:case_no, :disease_category, :result, :year, :link).map { |r| SolarExtraction::GoldSample::Row.new(*r) }
    selected = sampler.select_rows(rows)
    path = ENV["OUT_FILE"].presence ? Pathname(ENV["OUT_FILE"]) : SolarExtraction::GoldSample.default_path(size, seed)
    FileUtils.mkdir_p(path.dirname)
    File.write(path, sampler.csv(selected))

    puts "[solar] 표본 #{selected.size}건 (요청 #{size}, seed #{seed}) -> #{path}"
    puts "[solar] 층(질환군 / 판정 결과): 모집단 -> 표본"
    sampler.summary(rows, selected).each { |(category, result), (population, picked)| puts "  #{category} / #{result}: #{population} -> #{picked}" }
  end
end
