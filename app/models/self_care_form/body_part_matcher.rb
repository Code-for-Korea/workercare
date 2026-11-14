# frozen_string_literal: true

module SelfCareForm
  # 자유 입력 문장("왼쪽 손목", "경추 디스크")에서 챗봇 사전의 신체부위 개념을 찾는다.
  #
  # 이유: `burden_body_part_text` 필터는 부분 일치가 아니라 파이프 토큰 정확 일치라 문장 그대로는 0건이 된다.
  # 사전에는 한 글자 표기(목·등·손…)와 흔한 낱말과 겹치는 표기(하지·무지…)가 있어 단순 포함으로는
  # "등산 중 다침"이 등, "일을 하지 못해요"가 다리로 잡힌다. 엉뚱한 사례를 보여 주면 안 되므로:
  #   - 두 글자 이상 표기: 문장(공백 제거)에 포함되면 인정, 가장 긴 표기가 이긴다(동률은 사전 순서).
  #   - 한 글자 표기와 STRICT_SURFACES: ① 입력 전체(끝의 "통증"·"부위" 같은 군더더기 제외)가 그 표기이거나
  #     ② 공백으로 나눈 낱말 하나가 "그 표기 + 조사"일 때만 인정한다.
  #   - NON_BODY_WORDS는 매칭 전에 입력에서 지운다(사다리·전신주).
  class BodyPartMatcher
    Result = Data.define(:concept, :surface)

    PARTICLES = %w[이 가 을 를 은 는 도 에 의 만].freeze
    TRAILING_WORDS = %w[통증 부위 쪽 부분].freeze
    STRICT_SURFACES = %w[하지 무지 수지 두부].freeze
    NON_BODY_WORDS = %w[사다리 전신주].freeze

    class << self
      # @return [Result, nil] 찾은 개념과 일치한 표기. 없으면 nil(호출한 쪽이 조건 없이 검색하고 안내한다)
      def call(text)
        cleaned = NON_BODY_WORDS.reduce(text.to_s) { |memo, word| memo.gsub(word, " ") }.strip
        return nil if cleaned.empty?

        compact = cleaned.gsub(/\s+/, "")
        words = cleaned.split(/\s+/)
        whole = strip_trailing(compact)

        best = nil
        concepts.each do |concept, body|
          surfaces(concept, body).each do |surface|
            next unless matches?(surface, compact, words, whole)
            next if best && surface.length <= best.surface.length

            best = Result.new(concept: concept, surface: surface)
          end
        end
        best
      end

      private

      def concepts
        Chatbot::EntityDictionary.concepts("body_part")
      end

      def surfaces(concept, body)
        ([ concept ] + body[:colloquial] + body[:db]).map { |s| Chatbot::EntityDictionary.normalize(s) }.reject(&:empty?).uniq
      end

      def strict?(surface)
        surface.length == 1 || STRICT_SURFACES.include?(surface)
      end

      def matches?(surface, compact, words, whole)
        return compact.include?(surface) unless strict?(surface)

        whole == surface || words.any? { |word| word.start_with?(surface) && PARTICLES.include?(word.delete_prefix(surface)) }
      end

      # 끝의 군더더기("눈 통증" → "눈") 한 번 제거
      def strip_trailing(compact)
        word = TRAILING_WORDS.find { |w| compact.end_with?(w) && compact.length > w.length }
        word ? compact.delete_suffix(word) : compact
      end
    end
  end
end
