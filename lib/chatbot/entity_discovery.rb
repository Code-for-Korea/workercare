# frozen_string_literal: true

module Chatbot
  # 사전(EntityBuilder)이 아직 덮지 못하는 질병명 조각을 빈도순으로 보여 준다.
  # 판정서의 질병명은 '/'로 이어진 복합 값이 많아 조각으로 나눈 뒤 좌우 구분과 번호를 걷어 센다.
  class EntityDiscovery
    # '우측견관절...'처럼 붙어 있어도 떼지만, '우'/'좌'는 떨어진 단어일 때만 뗀다('우울증', '좌골'을 지키려고).
    SIDE_ATTACHED = /(?<![가-힣])(?:우측|좌측|양측)/
    SIDE_STANDALONE = /(?<![가-힣])(?:우|좌)(?=\s)/
    NUMBERING = %r{제?\s*\d[\d\s\-~/,.]*(?:번간|번|번째|간)?}
    SPLITTER = %r{[/,，、;]+}
    # 번호가 붙은 복합 값을 쪼개면 신체 부위만 남는 조각이 생긴다. 질병이 아니므로 센 결과에서 뺀다.
    ANATOMY_ONLY = %w[요추 요추부 요추간 경추 경추부 경추간 천추 흉추 견관절 슬관절 주관절 고관절 족관절 수관절 어깨 무릎 팔꿈치 손목 허리].freeze

    def initialize(builder, relation: DiseaseCase)
      @builder = builder
      @relation = relation
    end

    # [[조각, 건수], ...] 건수는 그 조각이 나온 판정서 수.
    def call(limit: 50, min_count: 10)
      patterns = @builder.covered_patterns
      counts = Hash.new(0)

      @relation.where.not(@builder.column => [ nil, "" ]).pluck(@builder.column).each do |raw|
        fragments(raw).uniq.each do |fragment|
          counts[fragment] += 1 unless covered?(fragment, patterns)
        end
      end

      counts.select { |_, count| count >= min_count }.sort_by { |fragment, count| [ -count, fragment ] }.first(limit)
    end

    def fragments(raw)
      raw.to_s.split(SPLITTER).filter_map do |part|
        cleaned = part.gsub(/\(.*?\)/, " ").gsub(NUMBERING, " ").gsub(SIDE_ATTACHED, " ").gsub(SIDE_STANDALONE, " ").gsub(/\s+/, " ").strip
        cleaned unless cleaned.length < 2 || ANATOMY_ONLY.include?(cleaned)
      end
    end

    private

    def covered?(fragment, patterns)
      squeezed = @builder.normalize(fragment)
      patterns.any? { |pattern| squeezed.include?(pattern) }
    end
  end
end
