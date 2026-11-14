# frozen_string_literal: true

module DiseaseCases
  # `/`·`/search` 화면에 입력칸이 없는 조건(직종 핵심어 `job_name_any[]`, 체크박스 목록에 없는
  # 신체부위 토큰)을 화면에 보여 주고 다시 검색해도 유지하기 위한 값 모음이다.
  # 단계형 자가진단의 "더 자세히 찾기" 링크가 이 조건들을 실어 보낸다. 같은 파라미터를 직접 만든 URL이나
  # `.md` 사용자가 보낼 수도 있으므로 "어디서 넘어왔는지"는 판단하지 않고 파라미터 모양만 본다.
  class CarriedFilters
    def initialize(params, checkbox_options:)
      @params = params
      @checkbox_options = Array(checkbox_options)
    end

    # 나타나는 조건: job_name_any가 있거나, 체크박스 목록에 없는 신체부위 토큰이 있을 때만.
    def present?
      job_keywords.any? || extra_body_tokens.any?
    end

    def job_keywords
      @job_keywords ||= Array(@params[:job_name_any]).map { |k| k.to_s.strip }.reject(&:empty?).uniq
    end

    def body_tokens
      @body_tokens ||= Array(@params[:burden_body_part]).map { |t| t.to_s.strip }.reject(&:empty?).uniq
    end

    # 체크박스로 그려지지 않아 hidden 필드로 유지해야 하는 토큰
    def extra_body_tokens
      @extra_body_tokens ||= body_tokens - @checkbox_options
    end

    def body_part?
      extra_body_tokens.any?
    end

    # 토큰 묶음이 어떤 개념의 BodyPartExpansion.tokens_for(개념)과 같으면 그 개념 이름, 아니면 nil.
    def body_concept
      return @body_concept if defined?(@body_concept)

      set = body_tokens.to_set
      @body_concept = Chatbot::EntityDictionary.db_by_concept("body_part").keys.find do |concept|
        Chatbot::BodyPartExpansion.tokens_for(concept).to_set == set
      end
    end

    # 이 조건만 지운 현재 화면 URL(링크용). 쪽 번호도 지운다.
    def path_without(request, *keys)
      query = request.query_parameters.except("page", *keys.map(&:to_s)).to_query
      query.empty? ? request.path : "#{request.path}?#{query}"
    end
  end
end
