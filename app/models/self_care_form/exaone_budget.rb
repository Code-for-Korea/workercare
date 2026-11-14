# frozen_string_literal: true

module SelfCareForm
  # EXAONE API의 하루 요청 한도(100회, 429와 재시도 포함)를 지키는 카운터. 모든 HTTP 요청을 센다.
  # 한도는 EXAONE_DAILY_REQUEST_CAP(기본 90, 여유 10)이고, 응답 헤더 x-day-rate-limit-remaining이 REMAINING_FLOOR 이하로
  # 내려오면 그 날은 더 부르지 않는다. 카운터는 Rails.cache에 둔다(프로세스를 넘어 유지하려면 운영의 solid_cache처럼
  # 공유 저장소여야 한다. 개발의 memory_store는 프로세스마다 따로 센다).
  module ExaoneBudget
    DEFAULT_CAP = 90
    REMAINING_FLOOR = 5

    class << self
      def cap
        Integer(ENV.fetch("EXAONE_DAILY_REQUEST_CAP", nil).presence || DEFAULT_CAP)
      rescue ArgumentError
        DEFAULT_CAP
      end

      def used
        Rails.cache.read(counter_key).to_i
      end

      # 요청 한 건을 센다(호출 직전에 부른다).
      def record_request!
        Rails.cache.increment(counter_key, 1, expires_in: 2.days) || Rails.cache.write(counter_key, 1, expires_in: 2.days)
      end

      # 응답 헤더가 알려 준 오늘 남은 횟수를 기억한다.
      def record_remaining(value)
        return if value.blank?

        Rails.cache.write(remaining_key, Integer(value), expires_in: 2.days)
      rescue ArgumentError, TypeError
        nil
      end

      def remaining_hint
        Rails.cache.read(remaining_key)
      end

      def available?
        return false if used >= cap

        hint = remaining_hint
        hint.nil? || hint > REMAINING_FLOOR
      end

      private

      def counter_key
        "exaone:requests:#{Date.current}"
      end

      def remaining_key
        "exaone:day_remaining:#{Date.current}"
      end
    end
  end
end
