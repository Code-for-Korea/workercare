# frozen_string_literal: true

require "fileutils"
require "json"
require "time"

module SolarExtraction
  # 과제 하나를 여러 건에 돌린다. 기본은 dry-run(건수·토큰·비용·시간 추정만, 네트워크·키 불필요)이고 apply: true일 때만 호출한다.
  #
  # - disease_cases는 필요한 컬럼만 읽는다(쓰기 없음). 후보 case_no는 가벼운 pluck으로 정하고, 본문은 200건씩 가져온다.
  # - 결과는 OUT_DIR의 results.jsonl(ok/invalid), failures.jsonl(재시도 소진 등)에 한 줄씩 이어 쓴다.
  # - 이어 받기: 두 파일을 읽어 끝낸 case_no는 건너뛴다. 실패 건은 다시 시도하되 skip_failed면 건너뛴다.
  # - 로그와 failures.jsonl에는 판정서 원문을 넣지 않는다(건수·토큰·비용·ETA, 오류 클래스와 고정 문구만).
  # - APPLY는 OUT_DIR/.lock에 flock을 잡아 같은 폴더의 동시 실행을 막는다(dry-run은 잡지 않는다).
  # - 워커가 예기치 않게 죽으면(예: 저장 실패) 중단하고 그 오류를 올린다. 처리하지 못한 건은 쓰지 않아 이어 받을 수 있다.
  # - INT/TERM을 받으면 새 건을 시작하지 않고 진행 중인 건만 마친 뒤 flush한다.
  class Runner
    SCOPE_EMPTY_ROWS = "empty_rows"
    FETCH_BATCH = 200
    CONSECUTIVE_FAILURE_LIMIT = 20
    MAX_CONCURRENCY = 8
    LENGTH_SQL = "length(coalesce(medical_records,'')) + length(coalesce(recognized_facts,'')) + length(coalesce(committee_decision,''))"
    EMPTY_ROWS_SQL = "coalesce(job_name,'') = '' AND coalesce(main_reasoning,'') = '' AND coalesce(work_relevance_eval,'') = ''"

    LOCK_FILE = ".lock"

    # 같은 OUT_DIR에서 다른 APPLY 실행이 돌고 있다.
    class Locked < SolarExtraction::Error; end

    Stats = Struct.new(:ok, :invalid, :failed, :prompt_tokens, :completion_tokens, :reasoning_tokens)

    attr_reader :stats, :abort_reason

    # client: extract(messages:, schema_name:, schema:, estimated_tokens:)와 model에 응답하는 객체(테스트에서 가짜를 넣는다).
    def initialize(task:, out_dir:, scope: "all", limit: nil, concurrency: 1, apply: false, client: nil, model: nil,
                   skip_failed: false, estimator: Estimator.new, progress_every: 50, io: $stdout, trap_signals: true,
                   price_in_per_m: Estimator::DEFAULTS[:price_in_per_m], price_out_per_m: Estimator::DEFAULTS[:price_out_per_m],
                   clock: -> { Process.clock_gettime(Process::CLOCK_MONOTONIC) })
      @task = task
      @store = ResultStore.new(out_dir)
      @scope = scope.presence || "all"
      @limit = limit
      @concurrency = concurrency.to_i.clamp(1, MAX_CONCURRENCY)
      @apply = apply
      @client = client
      @model = model
      @skip_failed = skip_failed
      @estimator = estimator
      @progress_every = [ progress_every.to_i, 1 ].max
      @io = io
      @trap_signals = trap_signals
      @price_in = price_in_per_m
      @price_out = price_out_per_m
      @clock = clock
      @stats = Stats.new(0, 0, 0, 0, 0, 0)
      @mutex = Mutex.new
      @consecutive_failures = 0
      @stop = false
      @worker_error = nil
    end

    def run
      return dry_run(*pending_cases) unless @apply

      # 락을 먼저 잡고 끝난 건을 읽는다(읽은 뒤에 잡으면 그 사이 다른 실행이 쓴 건을 또 처리한다)
      with_lock { apply(*pending_cases) }
    end

    private

    # OUT_DIR/.lock에 배타적 비차단 flock을 APPLY 동안 잡는다. 프로세스가 죽으면 OS가 풀어 준다.
    def with_lock
      FileUtils.mkdir_p(@store.dir)
      lock = File.open(@store.dir.join(LOCK_FILE), File::RDWR | File::CREAT, 0o600)
      unless lock.flock(File::LOCK_EX | File::LOCK_NB)
        raise Locked, "같은 출력 폴더(#{@store.dir})에서 다른 실행이 진행 중입니다. 끝난 뒤에 다시 실행하세요"
      end

      yield
    ensure
      lock&.close # 닫으면 락도 풀린다
    end

    # ---- 후보 선정 ----

    # @return [[Array<[case_no, chars]>, Hash]] 아직 안 한 후보(LIMIT 적용)와 건너뛴 건수
    def pending_cases
      rows = scope_relations.flat_map { |relation| relation.order(:id).pluck(:case_no, Arel.sql(LENGTH_SQL)) }
      done = @store.done_case_nos
      failed = @skip_failed ? @store.failed_case_nos - done : Set.new
      skipped = { done: 0, failed: 0 }
      pending = rows.reject do |case_no, _|
        if done.include?(case_no) then skipped[:done] += 1
        elsif failed.include?(case_no) then skipped[:failed] += 1
        end
      end
      pending = pending.first(@limit) if @limit
      [ pending, skipped.merge(scope_total: rows.size) ]
    end

    def scope_relations
      base = DiseaseCase.all
      kind, _, arg = @scope.partition(/[=:]/)
      case kind
      when "all" then [ base ]
      when SCOPE_EMPTY_ROWS then [ base.where(EMPTY_ROWS_SQL) ]
      when "disease_category" then [ base.where(disease_category: arg) ]
      when "case_nos"
        File.readlines(arg, chomp: true).map(&:strip).reject(&:empty?).uniq.each_slice(FETCH_BATCH).map { |slice| base.where(case_no: slice) }
      else raise ArgumentError, "알 수 없는 SCOPE입니다: #{@scope} (all | empty_rows | disease_category=… | case_nos=파일)"
      end
    end

    # ---- dry-run ----

    def dry_run(candidates, skipped)
      estimate = @estimator.estimate(candidates.map(&:last), @task.overhead_chars)
      @io.puts "[solar] DRY-RUN (과제=#{@task.name}, 프롬프트=#{@task.prompt_version}, 스키마=#{@task.schema_version}) 호출하지 않았습니다"
      @io.puts "[solar] 범위=#{@scope} 범위 전체=#{skipped[:scope_total]}건, 이미 끝냄=#{skipped[:done]}, 실패 건너뜀=#{skipped[:failed]}"
      @io.puts "[solar] 처리할 건수: #{estimate.cases}건 (동시성 #{@concurrency})"
      @io.puts "[solar] 추정 입력 토큰: #{estimate.input_tokens}, 추정 출력 토큰: #{estimate.output_tokens}"
      @io.puts format("[solar] 추정 비용: $%.2f", estimate.cost)
      @io.puts format("[solar] 추정 소요: %.1f분 (병목: %s)", estimate.minutes, estimate.bottleneck)
      @io.puts "[solar] 출력 위치: #{@store.dir}"
      @io.puts "[solar] 실제로 호출하려면 APPLY=1을 붙입니다 (UPSTAGE_API_KEY 필요)"
      { mode: :dry_run, estimate: estimate, skipped: skipped }
    end

    # ---- 실행 ----

    def apply(candidates, skipped)
      client = @client || Client.new(model: @model) # 키가 없으면 MissingApiKey
      total = candidates.size
      @io.puts "[solar] 시작: 과제=#{@task.name} 모델=#{client.model} #{total}건 (이미 끝냄 #{skipped[:done]}) 동시성=#{@concurrency}"
      @started = @clock.call
      @total = total
      @client_in_use = client
      previous = install_traps
      process_all(candidates)
      @io.puts "[solar] 중단 사유: #{@abort_reason}" if @abort_reason
      @io.puts "[solar] 끝: #{progress_line(final: true)}"
      { mode: :apply, stats: @stats, skipped: skipped, aborted: @abort_reason }
    ensure
      restore_traps(previous)
      @store.close
    end

    def process_all(candidates)
      queue = SizedQueue.new(@concurrency * 2)
      workers = Array.new(@concurrency) do
        Thread.new do
          while (item = queue.pop)
            process(item) unless stopping?
          end
        rescue StandardError => e
          # 저장 실패 등으로 워커가 죽으면 생산자가 가득 찬 큐에서 영영 막히지 않도록 멈추고 닫는다.
          # 처리하지 못한 건은 쓰지 않았으므로 다시 실행하면 이어 받는다.
          @mutex.synchronize { @worker_error ||= e }
          abort!("워커 오류(#{e.class.name})로 중단합니다")
          queue.close
        end
      end
      candidates.each_slice(FETCH_BATCH) do |slice|
        break if stopping?

        chars = slice.to_h
        records = DiseaseCase.where(case_no: slice.map(&:first)).select(:case_no, *Tasks::Base::INPUT_COLUMNS).index_by(&:case_no)
        slice.each do |case_no, _|
          break if stopping?

          record = records[case_no] or next
          begin
            queue << { case_no: case_no, input_text: @task.build_input(record), chars: chars[case_no] }
          rescue ClosedQueueError
            break # 워커가 죽어서 닫았다
          end
        end
      end
    ensure
      queue&.close
      workers&.each(&:join)
      raise @worker_error if @worker_error
    end

    def process(item)
      case_no = item[:case_no]
      if item[:input_text].nil?
        record_result(case_no, status: "invalid", output: nil, errors: [ "empty_input: 세 입력 컬럼이 모두 비어 있습니다" ], usage: nil, model: nil)
        return
      end

      reserve = @estimator.reserve_tokens(item[:chars], @task.overhead_chars)
      response = @client_in_use.extract(messages: @task.messages(item[:input_text]), schema_name: @task.schema_name,
                                        schema: @task.json_schema, estimated_tokens: reserve)
      validation = @task.validate(response.content, item[:input_text])
      status = validation.errors.empty? ? "ok" : "invalid"
      output = validation.output || response.content
      record_result(case_no, status: status, output: output, errors: validation.errors, usage: response.usage, model: response.model || @client_in_use.model)
    rescue StandardError => e
      record_failure(case_no, e)
    end

    def record_result(case_no, status:, output:, errors:, usage:, model:)
      @store.write_result(
        case_no: case_no, task: @task.name, model: model, prompt_version: @task.prompt_version, schema_version: @task.schema_version,
        status: status, output: output, validation_errors: errors, usage: usage, extracted_at: Time.now.utc.iso8601
      )
      @mutex.synchronize do
        status == "ok" ? @stats.ok += 1 : @stats.invalid += 1
        @consecutive_failures = 0
        if usage
          @stats.prompt_tokens += usage[:prompt_tokens].to_i
          @stats.completion_tokens += usage[:completion_tokens].to_i
          @stats.reasoning_tokens += usage[:reasoning_tokens].to_i
        end
        report_progress
      end
    end

    # 메시지는 이 모듈의 오류(고정 문구)만 남긴다. 그 밖의 예외는 메시지에 응답 조각이 섞일 수 있어 클래스만 남긴다.
    def record_failure(case_no, error)
      message = error.is_a?(SolarExtraction::Error) ? error.message : nil
      @store.write_failure(case_no: case_no, task: @task.name, error_class: error.class.name, message: message, failed_at: Time.now.utc.iso8601)
      @mutex.synchronize do
        @stats.failed += 1
        @consecutive_failures += 1
        abort!("#{error.class.name}: 되돌릴 수 없는 오류라 중단합니다") if fatal?(error)
        abort!("연속 #{CONSECUTIVE_FAILURE_LIMIT}건 실패라 중단합니다") if @consecutive_failures >= CONSECUTIVE_FAILURE_LIMIT
        report_progress
      end
    end

    # 키·크레딧·월 한도 문제는 다음 건도 똑같이 실패하므로 바로 멈춘다.
    def fatal?(error)
      error.is_a?(MissingApiKey) || (error.is_a?(ClientError) && (error.status == 401 || error.status == 403 || error.code == "usage_limit_exceeded"))
    end

    def abort!(reason)
      @abort_reason ||= reason
      @stop = true
    end

    def stopping? = @stop

    # ---- 진행 로그(mutex 안에서 호출) ----

    def processed = @stats.ok + @stats.invalid + @stats.failed

    def report_progress
      @io.puts "[solar] #{progress_line}" if (processed % @progress_every).zero?
    end

    def progress_line(final: false)
      elapsed = @clock.call - @started
      cost = ((@stats.prompt_tokens * @price_in) + (@stats.completion_tokens * @price_out)) / 1_000_000.0
      eta = processed.positive? ? elapsed / processed * (@total - processed) : nil
      line = "#{processed}/#{@total} (ok=#{@stats.ok} invalid=#{@stats.invalid} failed=#{@stats.failed}) " \
             "토큰 입력=#{@stats.prompt_tokens} 출력=#{@stats.completion_tokens}(추론 #{@stats.reasoning_tokens}) " \
             "#{format('$%.4f', cost)} 경과=#{(elapsed / 60.0).round(1)}분"
      line += " ETA=#{(eta / 60.0).round(1)}분" if eta && !final
      line
    end

    # ---- 시그널 ----

    def install_traps
      return {} unless @trap_signals

      %w[INT TERM].to_h { |signal| [ signal, Signal.trap(signal) { @stop = true } ] }
    end

    def restore_traps(previous)
      previous&.each { |signal, handler| Signal.trap(signal, handler || "DEFAULT") }
    end
  end
end
