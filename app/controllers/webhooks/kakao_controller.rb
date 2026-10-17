# frozen_string_literal: true

module Webhooks
  # 카카오 챗봇 스킬 서버 엔드포인트(POST /webhooks/kakao): 판정 사례 검색.
  # 인증·오류 응답·본문 파싱은 KakaoBaseController를 따른다.
  class KakaoController < KakaoBaseController
    def create
      started = now
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

    # 요청 ID·결과 건수·처리 시간만 기록한다. 발화 원문과 추출 값은 남기지 않는다(development-plan §9).
    def log_event(result, started)
      Rails.logger.info({
        event: "kakao_search",
        request_id: request.request_id,
        searched: !result.nil?,
        result_count: result&.total_count,
        over_cap: result&.over_cap,
        used_fallback: result&.used_fallback,
        duration_ms: elapsed_ms(started)
      }.to_json)
    end
  end
end
