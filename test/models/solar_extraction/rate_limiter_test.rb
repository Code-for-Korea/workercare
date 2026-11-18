# frozen_string_literal: true

require "test_helper"

class SolarExtraction::RateLimiterTest < ActiveSupport::TestCase
  # 기다리면 가짜 시계를 그만큼 앞으로 보낸다.
  setup do
    @now = 1000.0
    @sleeps = []
  end

  def limiter(rpm:, tpm:)
    SolarExtraction::RateLimiter.new(rpm: rpm, tpm: tpm, clock: -> { @now }, sleeper: ->(s) { @sleeps << s; @now += s })
  end

  test "한도 안에서는 기다리지 않는다" do
    l = limiter(rpm: 3, tpm: 1000)
    3.times { l.acquire(100) }
    assert_empty @sleeps
    assert_equal [ 3, 300 ], l.usage
  end

  test "RPM을 넘으면 가장 오래된 요청이 60초 창을 벗어날 때까지 기다린다" do
    l = limiter(rpm: 2, tpm: 100_000)
    l.acquire(1)
    @now += 10
    l.acquire(1)
    l.acquire(1)

    assert_equal 1, @sleeps.size
    assert_in_delta 50.0, @sleeps.sum, 0.1
    assert_operator @now, :>=, 1060.0
  end

  test "TPM을 넘으면 토큰이 풀릴 때까지 기다린다" do
    l = limiter(rpm: 100, tpm: 1000)
    l.acquire(600)
    @now += 20
    l.acquire(300)
    l.acquire(300) # 600+300+300 > 1000 -> 첫 예약(600)이 풀려야 한다

    assert_in_delta 40.0, @sleeps.sum, 0.1
    assert_equal [ 2, 600 ], l.usage
  end

  test "실제 사용량으로 보정하면 남는 토큰을 돌려받는다" do
    l = limiter(rpm: 100, tpm: 1000)
    reservation = l.acquire(900)
    l.reconcile(reservation, 100)
    l.acquire(800)

    assert_empty @sleeps
    assert_equal [ 2, 900 ], l.usage
  end

  test "TPM보다 큰 단일 요청도 영원히 막히지 않는다" do
    l = limiter(rpm: 10, tpm: 500)
    l.acquire(5000)
    assert_equal [ 1, 500 ], l.usage
  end

  test "여러 스레드가 공유해도 창 안 요청 수가 RPM을 넘지 않는다" do
    clock = Process.method(:clock_gettime)
    l = SolarExtraction::RateLimiter.new(rpm: 5, tpm: 1_000_000, clock: -> { clock.call(Process::CLOCK_MONOTONIC) }, sleeper: ->(_) { Thread.pass })
    taken = Queue.new
    threads = Array.new(4) { Thread.new { 2.times { l.acquire(1); taken << 1 } } }
    sleep 0.3
    assert_equal 5, taken.size
    assert_operator l.usage.first, :<=, 5
    threads.each(&:kill)
  end

  test "rpm·tpm이 1 미만이면 거부한다" do
    assert_raises(ArgumentError) { SolarExtraction::RateLimiter.new(rpm: 0, tpm: 10) }
  end
end
