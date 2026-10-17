# frozen_string_literal: true

module Chatbot
  # 사용자가 입력한 직종 검색어를 검색 토큰으로 정리한다. 입력 원문은 저장·로깅하지 않는다.
  module JobKeyword
    MAX_LENGTH = 30
    MAX_TOKENS = 3
    MIN_TOKEN_LENGTH = 2
    # 검색어가 아니라 말투인 단어. 토큰이 이 단어와 같으면 뺀다.
    STOPWORDS = %w[직종 직업 검색 검색해줘 찾기 찾아줘 알려줘 보여줘 사례 하는 일 일을 일하는 일해요].freeze
    TRAILING_ENDING = /(이에요|이요|예요|입니다)\z/
    # "조리 일 하는데요"의 '하는데요'처럼 직종이 아니라 문장 끝을 이루는 토큰.
    SENTENCE_ENDING = /\A(?:일)?(?:하는데요?|하고|해요|합니다|하고있어요|했어요)\z/

    class << self
      # 표시·전달용으로 정리한 검색어(구두점 제거, 공백 정리, 30자). 비면 nil.
      def clean(text)
        text.to_s.gsub(/[^\p{Hangul}\p{Alnum}\s]/, " ").squish.truncate(MAX_LENGTH, omission: "").strip.presence
      end

      # 검색에 쓸 토큰들. 2글자 미만과 말투 단어는 뺀다.
      def tokens(text)
        clean(text).to_s.split.map { |token| token.sub(TRAILING_ENDING, "") }
          .reject { |token| token.length < MIN_TOKEN_LENGTH || STOPWORDS.include?(token) || token.match?(SENTENCE_ENDING) }
          .uniq.first(MAX_TOKENS)
      end
    end
  end
end
