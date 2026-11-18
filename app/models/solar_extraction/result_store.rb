# frozen_string_literal: true

require "fileutils"
require "json"

module SolarExtraction
  # OUT_DIR 아래 results.jsonl / failures.jsonl을 이어 쓰는 저장소. 한 줄마다 flush하고 스레드에서 안전하다.
  # 이어 받기: 시작할 때 두 파일을 읽어 이미 끝낸 case_no를 알려 준다(깨진 줄은 건너뛴다).
  class ResultStore
    RESULTS = "results.jsonl"
    FAILURES = "failures.jsonl"

    attr_reader :dir

    def initialize(dir)
      @dir = Pathname(dir)
      @mutex = Mutex.new
      @files = {}
    end

    def results_path = @dir.join(RESULTS)
    def failures_path = @dir.join(FAILURES)

    # 결과(ok/invalid)가 있는 case_no 집합
    def done_case_nos = read_case_nos(results_path)

    # 실패 기록이 있는 case_no 집합(이후 성공했을 수 있으니 done과 빼서 쓴다)
    def failed_case_nos = read_case_nos(failures_path)

    def write_result(hash) = append(RESULTS, hash)

    def write_failure(hash) = append(FAILURES, hash)

    def close
      @mutex.synchronize do
        @files.each_value(&:close)
        @files.clear
      end
    end

    private

    def append(name, hash)
      line = JSON.generate(hash)
      @mutex.synchronize do
        file = (@files[name] ||= open_file(name))
        file.write(line, "\n")
        file.flush
      end
    end

    def open_file(name)
      FileUtils.mkdir_p(@dir)
      File.open(@dir.join(name), "a").tap { |file| file.sync = true }
    end

    def read_case_nos(path)
      return Set.new unless path.exist?

      path.each_line.each_with_object(Set.new) do |line, set|
        case_no = JSON.parse(line)["case_no"]
        set << case_no if case_no
      rescue JSON::ParserError
        next
      end
    end
  end
end
