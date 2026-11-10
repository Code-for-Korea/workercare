# frozen_string_literal: true

module SelfCareForm
  # 직접 입력한 직업 문구("용접사", "식당 서빙 일해요")에서 챗봇 사전의 직종 개념 이름을 찾는다.
  # **구글 폼으로 보내는 값을 정할 때만** 쓴다. 검색 조건(CaseFinder)에는 쓰지 않는다.
  #
  # 규칙(결정적, 추측하지 않는다):
  #   - 공백을 지운 입력이 개념 이름·구어 표기·db 표기와 같으면 그 개념(완전 일치).
  #   - 아니면 입력이 두 글자 이상 표기를 포함할 때, 가장 긴 표기가 이긴다.
  #   - 가장 긴 표기가 서로 다른 개념에 걸쳐 같은 길이로 비기면 찾지 못한 것으로 본다(호출한 쪽이 입력한 말을 보낸다).
  #   - 한 글자 표기는 포함으로는 보지 않는다(완전 일치만).
  class JobMatcher
    Result = Data.define(:concept, :surface)

    class << self
      # @return [Result, nil]
      def call(text)
        compact = Chatbot::EntityDictionary.normalize(text)
        return nil if compact.empty?

        candidates = []
        concepts.each do |concept, body|
          surfaces(concept, body).each do |surface|
            candidates << Result.new(concept: concept, surface: surface) if surface == compact
          end
        end
        return pick(candidates) if candidates.any?

        concepts.each do |concept, body|
          surfaces(concept, body).each do |surface|
            candidates << Result.new(concept: concept, surface: surface) if surface.length >= 2 && compact.include?(surface)
          end
        end
        pick(candidates)
      end

      private

      # 가장 긴 표기의 개념이 하나로 정해질 때만 돌려준다.
      def pick(candidates)
        return nil if candidates.empty?

        longest = candidates.map { |c| c.surface.length }.max
        top = candidates.select { |c| c.surface.length == longest }
        top.map(&:concept).uniq.one? ? top.first : nil
      end

      def concepts
        Chatbot::EntityDictionary.concepts("job_name")
      end

      def surfaces(concept, body)
        ([ concept ] + body[:colloquial] + body[:db]).map { |s| Chatbot::EntityDictionary.normalize(s) }.reject(&:empty?).uniq
      end
    end
  end
end
