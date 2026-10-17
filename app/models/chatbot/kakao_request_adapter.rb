# frozen_string_literal: true

module Chatbot
  # 카카오 스킬 payload를 내부 검색 조건으로 정규화한다.
  #
  # - 엔티티 값은 action.params만 읽는다. detailParams의 origin은 발화 조각 원문이다.
  # - userRequest.utterance(발화 원문)는 읽지 않는다. 저장·로깅 금지(project-plan §9).
  # - 바로연결 버튼(다른 사례 보기 등)은 엔티티를 다시 추출하지 않으므로
  #   버튼의 extra로 전달된 조건을 clientExtra에서 이어받는다. action.params의 값이 우선한다.
  # - 단계별 사례 찾기는 블록마다 컨텍스트로 값을 이어 받는다. '모르겠어요'로 넘긴 단계는 값이 비거나
  #   '모름'으로, 해석되지 않은 참조는 '#wiz2.disease_name'·'$body_part' 같은 문자열로 올 수 있어
  #   모두 '조건 없음'으로 취급한다.
  class KakaoRequestAdapter
    RESULT_BY_LABEL = {
      "인정" => "approved",
      "불인정" => "rejected",
      "일부인정" => "partially_approved",
      "변경인정" => "revised_approved"
    }.freeze
    ANY_RESULT_LABELS = %w[전체 모두 상관없음 all].freeze
    MAX_VALUE_LENGTH = 100
    MAX_PAGE = 100
    SKIP_VALUE = "모름"

    Conditions = Struct.new(:disease_name, :body_part, :job_name, :work_factor, :result, :ignored, keyword_init: true) do
      def empty?
        [ disease_name, body_part, job_name, work_factor, result ].all?(&:blank?)
      end

      def to_extra
        {
          "disease_name" => disease_name,
          "body_part" => body_part,
          "job_name" => job_name,
          "work_factor" => work_factor,
          "decision_type" => result
        }.compact
      end
    end

    def initialize(payload)
      @payload = payload.is_a?(Hash) ? payload : {}
    end

    def conditions
      @conditions ||= build_conditions
    end

    def page
      @page ||= client_extra["page"].to_i.clamp(0, MAX_PAGE)
    end

    # 소유권 검증용 해시(검색 세션 도입 시 사용). 평문 식별자는 보관하지 않는다.
    def user_key_digest
      key = fetch_path("userRequest", "user", "id").to_s
      key.empty? ? nil : Digest::SHA256.hexdigest(key)
    end

    private

    def build_conditions
      params = fetch_path("action", "params")
      params = {} unless params.is_a?(Hash)

      ignored = []
      raw_decision = value_for("decision_type", params)
      result = nil
      if raw_decision.present?
        result = normalize_result(raw_decision)
        ignored << "decision_type" if result.nil? && !ANY_RESULT_LABELS.include?(raw_decision)
      end

      Conditions.new(
        disease_name: value_for("disease_name", params),
        body_part: value_for("body_part", params),
        job_name: value_for("job_name", params),
        work_factor: value_for("work_factor", params),
        result: result,
        ignored: ignored
      )
    end

    def value_for(key, params)
      text = clean(params[key]).presence || clean(client_extra[key])
      text
    end

    def clean(value)
      return nil unless value.is_a?(String)

      text = value.strip.truncate(MAX_VALUE_LENGTH, omission: "").presence
      return nil if text == SKIP_VALUE || text&.start_with?("#", "$")

      text
    end

    def client_extra
      extra = fetch_path("action", "clientExtra")
      extra.is_a?(Hash) ? extra : {}
    end

    # Hash#dig는 중간 값이 Hash가 아니면 TypeError를 내므로, 외부 입력에는 안전한 탐색을 쓴다.
    def fetch_path(*keys)
      keys.reduce(@payload) { |node, key| node.is_a?(Hash) ? node[key] : (return nil) }
    end

    def normalize_result(label)
      return label if DiseaseCase.results.key?(label)

      RESULT_BY_LABEL[label]
    end
  end
end
