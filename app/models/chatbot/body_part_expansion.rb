# frozen_string_literal: true

module Chatbot
  # 신체부위 대표(엔티티 값)를 DB의 burden_body_part 토큰 목록으로 확장한다.
  #
  # burden_body_part는 파이프로 이어진 값이고 서버 필터(DiseaseCase.apply_main_filters)가 토큰을
  # 정확히 일치시킨다. 그래서 '어깨'만 찾으면 '우측 어깨'를 놓친다(어깨 12,995건 → 좌우 변형 포함 16,092건).
  # 사전(config/chatbot/entities/body_part.yml)의 db 토큰에 좌우 접두 변형을 붙여 모두 찾게 한다.
  module BodyPartExpansion
    DICTIONARY_PATH = "config/chatbot/entities/body_part.yml"
    # 좌우 구분 표기. 빈 문자열은 접두 없는 원래 토큰이다. 개발 DB의 신체부위 토큰 82,938개 중
    # 이 4가지가 99.38%이고, 나머지(왼쪽·오른쪽·양쪽·양·우·좌)는 합쳐 0.62%다. 값이 늘어나는 만큼
    # 검색이 느려져(5초 응답 제한) 나머지는 일부러 뺐다.
    SIDE_PREFIXES = [ "", "우측 ", "좌측 ", "양측 " ].freeze

    class << self
      # 대표 엔트리 → 필터에 쓸 토큰들. 사전에 없는 값은 그 값 자체(와 좌우 변형)를 쓴다.
      def tokens_for(label)
        label = label.to_s.strip
        return [] if label.empty?

        expand(dictionary.fetch(normalize(label), [ label ]))
      end

      def expand(tokens)
        tokens.flat_map { |token| SIDE_PREFIXES.map { |prefix| "#{prefix}#{token}" } }.uniq
      end

      def reset!
        @dictionary = nil
      end

      private

      def dictionary
        @dictionary ||= load_dictionary
      end

      def load_dictionary
        path = Rails.root.join(DICTIONARY_PATH)
        return {} unless path.exist?

        YAML.safe_load_file(path).fetch("concepts", {}).to_h do |name, body|
          [ normalize(name), Array(body["db"]).map(&:to_s) ]
        end
      end

      def normalize(text)
        text.to_s.gsub(/\s+/, "")
      end
    end
  end
end
