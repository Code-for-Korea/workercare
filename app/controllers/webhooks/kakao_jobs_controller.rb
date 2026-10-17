# frozen_string_literal: true

module Webhooks
  # 직종 검색 스킬(POST /webhooks/kakao/jobs): 직종 검색어 → 후보 직종 목록 → 여러 개 선택.
  # 선택을 마치면 `선택한 직종으로 찾기` 버튼이 판정 사례 검색 스킬(POST /webhooks/kakao)을
  # job_names와 함께 부른다. 인증·오류 응답은 KakaoBaseController를 따른다.
  class KakaoJobsController < KakaoBaseController
    def create
      started = now
      request_info = Chatbot::JobSearchRequest.new(parse_payload)
      candidates = nil

      body =
        if request_info.keyword.nil?
          # 검색어가 없으면(입력 대기 중이 아닌 발화, 시작 블록 호출 등) 직종을 입력하라고 안내한다.
          Chatbot::JobResponseBuilder.prompt
        else
          # 엔티티 대표(예: 조리원)가 오면 사전의 핵심어들로 넓혀 찾는다. 그 외에는 검색어를 토큰으로 나눈다.
          stems = Chatbot::JobExpansion.stems_for(request_info.keyword)
          tokens = stems || Chatbot::JobKeyword.tokens(request_info.keyword)
          candidates = Chatbot::JobCandidates.new(tokens).call
          # 요약과 extra에는 사용자가 친 문장이 아니라 검색에 쓴 값(대표 또는 토큰)을 싣는다.
          # 대표를 그대로 싣기 때문에 쪽 이동 같은 후속 요청에서도 같은 확장이 적용된다.
          search_keyword = stems ? request_info.keyword : tokens.join(" ")
          if tokens.empty?
            Chatbot::JobResponseBuilder.prompt(note: "두 글자 이상의 직종 이름으로 입력해 주세요.")
          elsif candidates.empty?
            Chatbot::JobResponseBuilder.no_match(search_keyword)
          else
            Chatbot::JobResponseBuilder.candidates(
              keyword: search_keyword, candidates: candidates, page: request_info.page,
              selected: request_info.selected, cap_reached: request_info.cap_reached?
            )
          end
        end

      log_event(request_info, candidates, started)
      render json: body
    end

    private

    # 요청 ID·출처·후보/선택 개수·쪽·처리 시간만 기록한다. 검색어와 직종 이름은 남기지 않는다.
    def log_event(request_info, candidates, started)
      Rails.logger.info({
        event: "kakao_job_search",
        request_id: request.request_id,
        keyword_source: request_info.source,
        candidate_count: candidates&.size,
        selected_count: request_info.selected.size,
        page: request_info.page,
        duration_ms: elapsed_ms(started)
      }.to_json)
    end
  end
end
