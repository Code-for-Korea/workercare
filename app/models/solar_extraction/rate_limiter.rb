# frozen_string_literal: true

module SolarExtraction
  # 스레드 사이에서 공유하는 RPM·TPM 제한기. 최근 60초 창(sliding window)의 요청 수와 토큰 합을 함께 지킨다.
  # 호출 전에 추정 토큰을 예약(acquire)하고, 호출 뒤 실제 사용량으로 보정(reconcile)한다.
  # 기본값은 Tier 0(100 RPM, 250K TPM)이다(docs/ext/solar/rate-limits.md). 계정 등급은 콘솔에서 확인한다.
  # 서버 쪽 한도와 어긋나지 않도록 실제 한도보다 약간 낮게(예: RPM=90) 주는 것을 권한다.
  class RateLimiter
    WINDOW = 60.0
    DEFAULT_RPM = 100
    DEFAULT_TPM = 250_000

    Reservation = Struct.new(:time, :tokens)

    attr_reader :rpm, :tpm

    def self.from_env(env = ENV, **options)
      new(rpm: Integer(env["RPM"].presence || DEFAULT_RPM), tpm: Integer(env["TPM"].presence || DEFAULT_TPM), **options)
    end

    # clock: 단조 증가하는 초 단위 시각을 주는 callable. sleeper: 초 단위로 기다리는 callable(테스트에서 바꿔 끼운다).
    def initialize(rpm: DEFAULT_RPM, tpm: DEFAULT_TPM, clock: -> { Process.clock_gettime(Process::CLOCK_MONOTONIC) }, sleeper: ->(seconds) { sleep(seconds) })
      raise ArgumentError, "rpm과 tpm은 1 이상이어야 합니다" if rpm.to_i < 1 || tpm.to_i < 1

      @rpm = rpm.to_i
      @tpm = tpm.to_i
      @clock = clock
      @sleeper = sleeper
      @mutex = Mutex.new
      @entries = []
    end

    # 한도 안에 들어갈 때까지 기다린 뒤 예약을 돌려준다. TPM보다 큰 단일 요청은 TPM으로 잘라 예약한다(영영 못 지나가는 것을 막는다).
    def acquire(tokens)
      tokens = [ [ tokens.to_i, 0 ].max, @tpm ].min
      loop do
        reservation = nil
        wait = @mutex.synchronize do
          now = @clock.call
          prune(now)
          if @entries.size < @rpm && used_tokens + tokens <= @tpm
            reservation = Reservation.new(now, tokens)
            @entries << reservation
            0
          else
            next_release(now, tokens)
          end
        end
        return reservation if reservation

        @sleeper.call(wait)
      end
    end

    # 실제 사용 토큰으로 예약을 고친다(창 안에 있을 때만 의미가 있다).
    def reconcile(reservation, actual_tokens)
      return if reservation.nil? || actual_tokens.nil?

      @mutex.synchronize { reservation.tokens = [ actual_tokens.to_i, 0 ].max }
    end

    # 지금 창 안의 [요청 수, 토큰 합]
    def usage
      @mutex.synchronize do
        prune(@clock.call)
        [ @entries.size, used_tokens ]
      end
    end

    private

    def prune(now)
      @entries.reject! { |entry| entry.time <= now - WINDOW }
    end

    def used_tokens
      @entries.sum(&:tokens)
    end

    # 요청 수 한도를 풀어 줄 가장 이른 시각, 토큰 한도를 풀어 줄 가장 이른 시각 중 늦은 쪽까지 기다린다.
    def next_release(now, tokens)
      release_at = now
      release_at = [ release_at, @entries.first.time + WINDOW ].max if @entries.size >= @rpm
      if used_tokens + tokens > @tpm
        freed = used_tokens + tokens - @tpm
        sum = 0
        @entries.each do |entry|
          sum += entry.tokens
          if sum >= freed
            release_at = [ release_at, entry.time + WINDOW ].max
            break
          end
        end
      end
      [ release_at - now, 0.01 ].max
    end
  end
end
