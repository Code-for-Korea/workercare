# frozen_string_literal: true

require "csv"
require "yaml"

module Chatbot
  # 카카오 챗봇 관리자센터에 업로드할 엔티티 CSV를 사전(YAML)에서 만든다.
  #
  # 사전 한 항목은 '개념'이다. 개념명이 대표 엔트리가 되고, 동의어는 DB 표기 변형(db)과
  # 사용자 표현(colloquial)을 합쳐 만든다. 건수는 match 방식으로 센다.
  #
  #   like  (기본) 공백을 무시한 부분 일치(LIKE). 질병명·직종처럼 자유 텍스트 컬럼.
  #   exact        컬럼 값 일치. 판정 결과(enum)처럼 값이 고정된 컬럼. db에는 enum 값을 적는다.
  #   fts          서버의 DiseaseCase.main_search(q:)로 측정. db에는 q로 보낼 검색어를 적는다.
  #   token        파이프로 이어진 burden_body_part 토큰. 서버 필터(apply_main_filters)로 재고, 좌우 접두
  #                변형(Chatbot::BodyPartExpansion)까지 합쳐 센다. db에는 접두 없는 기본 토큰을 적는다.
  #   static       건수가 없는 고정 목록(예: '모름' 같은 답). 모든 개념을 사전 순서대로 그대로 출력한다.
  #
  # exclude_synonyms: 건수 측정(db)에는 쓰지만 CSV 동의어에서는 뺄 표현. 다른 엔티티와 같은 표현을
  # 동의어로 올리면 카카오가 인식을 못 하므로 한쪽에서 뺄 때 쓴다(cross_entity_errors).
  class EntityBuilder
    class InvalidDictionary < StandardError; end

    Row = Struct.new(:representative, :synonyms, :hits, :plain_hits, keyword_init: true)

    CONFIG_DIR = "config/chatbot/entities"
    MATCH_MODES = %w[like exact fts token static].freeze
    TOKEN_COLUMN = "burden_body_part"
    REPORT_LABELS = {
      "like" => [ "단순 LIKE", "공백무시+표기변형" ],
      "exact" => [ "건수", "합계" ],
      "fts" => [ "q=대표어", "q 변형 합집합" ],
      "token" => [ "대표 토큰만", "좌우 변형 합집합" ],
      "static" => [ "-", "-" ]
    }.freeze
    ENTITY_NAME = /\A[a-z_]+\z/

    attr_reader :column, :min_hits, :concepts, :match

    def self.config_path(entity, root: Rails.root)
      raise ArgumentError, "알 수 없는 엔티티 이름: #{entity.inspect}" unless entity.to_s.match?(ENTITY_NAME)

      root.join(CONFIG_DIR, "#{entity}.yml")
    end

    # 같은 표현(공백 무시)이 서로 다른 엔티티의 대표 엔트리·동의어에 걸치면 카카오가 어느 쪽인지 판단하기 어렵다.
    # builders: { "엔티티 이름" => EntityBuilder }. 업로드되는 표현(대표 + 동의어)만 비교한다.
    def self.cross_entity_errors(builders)
      owners = Hash.new { |hash, key| hash[key] = [] }
      builders.each do |entity, builder|
        builder.concepts.each_key do |name|
          builder.terms_for(name).each { |term| owners[builder.normalize(term)] << "#{entity}:#{name}" }
        end
      end

      owners.filter_map do |term, list|
        next if list.map { |owner| owner.split(":", 2).first }.uniq.size < 2

        "'#{term}'이(가) 여러 엔티티에 중복됩니다: #{list.uniq.join(' | ')}"
      end.sort
    end

    def self.load(entity, relation: DiseaseCase, root: Rails.root)
      from_file(config_path(entity, root: root), relation: relation)
    end

    def self.from_file(path, relation: DiseaseCase)
      new(YAML.safe_load_file(path), relation: relation)
    end

    def initialize(config, relation: DiseaseCase)
      @relation = relation
      @match = config.fetch("match", "like").to_s
      raise InvalidDictionary, "match는 #{MATCH_MODES.join('/')} 중 하나여야 합니다: #{@match}" unless MATCH_MODES.include?(@match)

      @column = (@match == "token" ? TOKEN_COLUMN : config.fetch("column", "q")).to_s
      @min_hits = config.fetch("min_hits", 5).to_i
      @concepts = config.fetch("concepts").to_h do |name, body|
        [ name.to_s, {
          db: Array(body["db"]).map(&:to_s),
          colloquial: Array(body["colloquial"]).map(&:to_s),
          exclude: Array(body["exclude_synonyms"]).map(&:to_s)
        } ]
      end
      return if %w[fts static].include?(@match) # q 검색과 고정 목록은 컬럼과 무관하다

      raise InvalidDictionary, "컬럼 이름이 올바르지 않습니다: #{@column}" unless @column.match?(/\A\w+\z/) && relation.column_names.include?(@column)
    end

    # DB 없이 검사할 수 있는 사전 오류 목록.
    def structural_errors
      errors = []
      owners = Hash.new { |hash, key| hash[key] = [] }

      concepts.each do |name, body|
        errors << "개념명이 비어 있습니다" if name.strip.empty?
        errors << "#{name}: db 표기가 하나도 없습니다(건수를 측정할 수 없음)" if body[:db].empty? && match != "static"
        errors << "#{name}: 동의어(colloquial·db)가 하나도 없습니다" if match == "static" && (body[:colloquial] + body[:db]).empty?
        known = (body[:colloquial] + body[:db]).map { |term| normalize(term) }
        body[:exclude].each do |term|
          errors << "#{name}: exclude_synonyms의 '#{term}'이(가) 이 개념의 db·colloquial에 없습니다" unless known.include?(normalize(term))
          errors << "#{name}: 대표 엔트리 '#{name}'은(는) 동의어 제외 대상이 아닙니다" if normalize(term) == normalize(name)
        end
        terms_for(name).each do |term|
          errors << "#{name}: 연속 공백이 있는 표현 '#{term}' (글자 사이 공백은 최대 1자)" if term.match?(/\s{2,}/)
          errors << "#{name}: 빈 표현이 있습니다" if term.strip.empty?
          owners[normalize(term)] << name
        end
      end

      owners.each do |term, names|
        errors << "'#{term}'이(가) 여러 개념에 중복됩니다: #{names.uniq.join(', ')}" if names.uniq.size > 1
      end
      errors
    end

    def validate!
      errors = structural_errors
      raise InvalidDictionary, "사전 오류 #{errors.size}건:\n- #{errors.join("\n- ")}" if errors.any?

      self
    end

    # 건수가 min_hits 이상인 개념의 CSV 행. 건수가 많은 순, 같으면 사전 순서.
    # static 방식은 건수가 없으므로 모든 개념을 사전 순서대로 낸다.
    def rows
      @rows ||= begin
        validate!
        if match == "static"
          measured
        else
          measured.select { |row| row.hits >= min_hits }
            .sort_by.with_index { |row, index| [ -row.hits, index ] }
        end
      end
    end

    def dropped
      validate!
      return [] if match == "static"

      measured.reject { |row| row.hits >= min_hits }
    end

    # 카카오 관리자센터 업로드 샘플과 같은 형식: 헤더 없음, 첫 열이 대표 엔트리, 동의어는 열마다 하나씩,
    # 모든 행을 같은 폭으로 맞추기 위해 모자란 칸은 빈 칸(nil)으로 채운다.
    def to_csv
      table = rows.map { |row| [ row.representative, *row.synonyms ] }
      width = table.map(&:size).max.to_i
      CSV.generate do |csv|
        table.each { |cells| csv << cells.fill(nil, cells.size...width) }
      end
    end

    def write_csv(path)
      File.write(path, to_csv, encoding: "UTF-8")
    end

    # 사전의 모든 db 표기 중 하나라도 걸리는 전체 사례 수와 그 비율. static 방식은 건수가 없어 nil.
    def coverage
      return nil if match == "static"

      patterns = rows.flat_map { |row| concepts.fetch(row.representative)[:db] }
      matched = count_matching(patterns)
      total = @relation.count
      { matched: matched, total: total, ratio: total.zero? ? 0.0 : matched.to_f / total }
    end

    def report
      lines = []
      if match == "static"
        rows.each { |row| lines << format("%-22s 동의어 %d개", row.representative, row.synonyms.size) }
        lines << ""
        lines << "대표 엔트리 #{rows.size}개, 동의어 #{rows.sum { |row| row.synonyms.size }}개 (건수 없는 고정 목록)"
        return lines.join("\n")
      end

      plain_label, union_label = REPORT_LABELS.fetch(match)
      lines << format("%-22s %10s %14s %7s", "대표 엔트리", plain_label, union_label, "재현율")
      rows.each do |row|
        recall = row.hits.zero? ? "-" : "#{(row.plain_hits * 100.0 / row.hits).round}%"
        lines << format("%-22s %10d %14d %7s", row.representative, row.plain_hits, row.hits, recall)
      end
      cov = coverage
      lines << ""
      lines << "대표 엔트리 #{rows.size}개, 동의어 #{rows.sum { |row| row.synonyms.size }}개"
      lines << "사전이 덮는 사례: #{cov[:matched]} / #{cov[:total]} (#{(cov[:ratio] * 100).round(1)}%)"
      lines << "제외(합계 #{min_hits}건 미만): #{dropped.map { |row| "#{row.representative}(#{row.hits})" }.join(', ')}" if dropped.any?
      lines.join("\n")
    end

    # 동의어 = 사용자 표현 + DB 표기 변형. 대표 엔트리와 같은 표현(공백 무시)과 중복은 뺀다.
    def synonyms_for(name)
      body = concepts.fetch(name)
      (body[:colloquial] + visible_db(body))
        .reject { |term| normalize(term) == normalize(name) || excluded?(body, term) }
        .uniq { |term| normalize(term) }
    end

    def terms_for(name)
      body = concepts.fetch(name)
      ([ name ] + body[:colloquial] + visible_db(body)).reject { |term| term != name && excluded?(body, term) }
    end

    def excluded?(body, term)
      body[:exclude].any? { |excluded| normalize(excluded) == normalize(term) }
    end

    def normalize(term)
      term.to_s.gsub(/\s+/, "")
    end

    # 이미 사전에 있는 표기인지(공백 무시, 부분 포함) 확인할 때 쓰는 정규화된 패턴 목록.
    def covered_patterns
      concepts.values.flat_map { |body| body[:db] }.map { |term| normalize(term) }.uniq
    end

    private

    def measured
      @measured ||= concepts.map do |name, body|
        next Row.new(representative: name, synonyms: synonyms_for(name), hits: nil, plain_hits: nil) if match == "static"

        Row.new(
          representative: name,
          synonyms: synonyms_for(name),
          hits: count_matching(body[:db]),
          plain_hits: count_plain(name)
        )
      end
    end

    # exact 방식의 db는 enum 값이라 사용자가 말하는 표현이 아니다. 동의어·중복 검사에서 뺀다.
    def visible_db(body)
      match == "exact" ? [] : body[:db]
    end

    def count_matching(terms)
      case match
      when "exact" then @relation.where(@column => terms.uniq).count
      when "fts" then fts_ids(terms).size
      when "token" then count_tokens(BodyPartExpansion.expand(terms))
      else count_like(terms)
      end
    end

    # 서버와 같은 필터(apply_main_filters의 burden_body_part, 파이프 경계 정확 일치)로 센다.
    def count_tokens(tokens)
      @relation.apply_main_filters(@relation.all, burden_body_part: tokens).count
    end

    def count_like(terms)
      patterns = terms.map { |term| normalize(term) }.reject(&:empty?).uniq
      return 0 if patterns.empty?

      condition = Array.new(patterns.size, "REPLACE(#{@column}, ' ', '') LIKE ?").join(" OR ")
      binds = patterns.map { |pattern| "%#{@relation.sanitize_sql_like(pattern)}%" }
      @relation.where(condition, *binds).count
    end

    # 서버가 대표 엔트리 하나만 받았을 때의 건수.
    #  like: 지금 서버(apply_main_filters)와 같은 단순 부분 일치 / fts: q=대표어 / exact: 개념 자신의 값
    def count_plain(name)
      case match
      when "exact" then count_matching(concepts.fetch(name)[:db])
      when "fts" then fts_ids([ name ]).size
      when "token" then count_tokens([ name ])
      else @relation.where("#{@column} LIKE ?", "%#{@relation.sanitize_sql_like(name)}%").count
      end
    end

    # q 검색어마다 main_search(전문 검색 + 폴백)로 찾은 사례 id의 합집합.
    def fts_ids(terms)
      terms.map(&:to_s).reject { |term| term.strip.empty? }.uniq.flat_map do |term|
        scope, = @relation.main_search(q: term)
        scope.reorder(nil).pluck("disease_cases.id")
      end.uniq
    end
  end
end
