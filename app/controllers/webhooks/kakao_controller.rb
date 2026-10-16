# frozen_string_literal: true

module Webhooks
  # 카카오 챗봇 스킬 서버 엔드포인트(POST /webhooks/kakao).
  #
  # - ActionController::API: 카카오 요청은 CSRF 토큰이 없고 브라우저 전용 필터도 필요 없다.
  # - 항상 HTTP 200과 유효한 version 2.0 본문을 돌려준다(타임아웃 5초 고정, 오류도 안내 응답으로).
  # - 카카오 payload의 최상위 "action" 키가 Rails의 params[:action]과 충돌하므로
  #   본문은 raw_post를 직접 파싱한다.
  # - 인증: 카카오 스킬 설정의 사용자 정의 헤더 값(공유 비밀)만 제공된다.
  class KakaoController < ActionController::API
    TOKEN_HEADER = "X-Skill-Token"

    # 토큰이 설정되지 않았을 때 인증 없이 허용할지 여부. 개발·테스트 환경에서만 기본 허용.
    class_attribute :allow_blank_token, default: Rails.env.local?

    before_action :authenticate_skill_request!

    rescue_from StandardError do |error|
      Rails.logger.error({ event: "kakao_skill_error", error_class: error.class.name }.to_json)
      render json: Chatbot::KakaoResponseBuilder.error
    end

    def create
      started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      adapter = Chatbot::KakaoRequestAdapter.new(parse_payload)
      conditions = adapter.conditions

      if conditions.empty?
        body = Chatbot::KakaoResponseBuilder.ask_conditions
        result = nil
      else
        result = Chatbot::CaseSearch.new(conditions, page: adapter.page).call
        body = if result.cases.empty?
          Chatbot::KakaoResponseBuilder.no_result(conditions)
        else
          Chatbot::KakaoResponseBuilder.results(result, conditions)
        end
      end

      log_event(result, started)
      render json: body
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

    # 요청 ID·결과 건수·처리 시간만 기록한다. 발화 원문과 추출 값은 남기지 않는다(development-plan §9).
    def log_event(result, started)
      Rails.logger.info({
        event: "kakao_search",
        request_id: request.request_id,
        searched: !result.nil?,
        result_count: result&.total_count,
        over_cap: result&.over_cap,
        used_fallback: result&.used_fallback,
        duration_ms: ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started) * 1000).round
      }.to_json)
    end
  end
end
