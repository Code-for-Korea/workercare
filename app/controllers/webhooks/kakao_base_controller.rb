# frozen_string_literal: true

module Webhooks
  # 카카오 챗봇 스킬 엔드포인트의 공통 동작.
  #
  # - ActionController::API: 카카오 요청은 CSRF 토큰이 없고 브라우저 전용 필터도 필요 없다.
  # - 항상 HTTP 200과 유효한 version 2.0 본문을 돌려준다(타임아웃 5초 고정, 오류도 안내 응답으로).
  # - 카카오 payload의 최상위 "action" 키가 Rails의 params[:action]과 충돌하므로
  #   본문은 raw_post를 직접 파싱한다.
  # - 인증: 카카오 스킬 설정의 사용자 정의 헤더 값(공유 비밀)만 제공된다. 스킬마다 같은 값을 쓴다.
  class KakaoBaseController < ActionController::API
    TOKEN_HEADER = "X-Skill-Token"

    # 토큰이 설정되지 않았을 때 인증 없이 허용할지 여부. 개발·테스트 환경에서만 기본 허용.
    class_attribute :allow_blank_token, default: Rails.env.local?

    before_action :authenticate_skill_request!

    rescue_from StandardError do |error|
      Rails.logger.error({ event: "kakao_skill_error", error_class: error.class.name }.to_json)
      render json: Chatbot::KakaoResponseBuilder.error
    end

    private

    def authenticate_skill_request!
      expected = skill_token
      if expected.blank?
        head :unauthorized unless allow_blank_token
        return
      end

      provided = request.headers[TOKEN_HEADER].to_s
      head :unauthorized unless ActiveSupport::SecurityUtils.secure_compare(provided, expected)
    end

    def skill_token
      ENV["KAKAO_SKILL_TOKEN"].presence || Rails.application.credentials.dig(:kakao, :skill_token)
    end

    def parse_payload
      JSON.parse(request.raw_post)
    rescue JSON::ParserError
      {}
    end

    def now
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end

    def elapsed_ms(started)
      ((now - started) * 1000).round
    end
  end
end
