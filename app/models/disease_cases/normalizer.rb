module DiseaseCases
  # application_type / work_type / employment_type 값을 표준 표기로 바꾼다 (순수 함수, DB 접근 없음).
  # 규칙은 config/normalization/rules.yml, 설명은 docs/disease-cases-normalization.md.
  # 반환값은 Result(value, detail): value는 컬럼에 덮어쓸 값, detail은 *_detail 컬럼에 보존할 원문 일부.
  class Normalizer
    Result = Data.define(:value, :detail)
    BLANK = Result.new(nil, nil)

    RULES = YAML.safe_load_file(Rails.root.join("config/normalization/rules.yml"), freeze: true).freeze
    PAREN = /\([^()]*\)|（[^（）]*）/

    class << self
      # NULL, "", 공백만 있는 값(전각·NBSP·제로폭 포함)은 모두 nil.
      def blank_to_nil(value)
        text = clean(value)
        text.empty? ? nil : value.to_s.unicode_normalize(:nfkc).strip
      end

      # death_status 등: 빈값과 허용값 밖의 값은 nil.
      def enum_value(column, value)
        text = blank_to_nil(value)
        RULES.fetch("enums").fetch(column.to_s).include?(text) ? text : nil
      end

      # 신청서 종류 → 토큰을 `|`로 결합. 해당 토큰이 없으면 "기타" + 원문 전체를 detail에.
      def application_type(value)
        original = blank_to_nil(value) or return BLANK
        rules = RULES.fetch("application_type")
        return Result.new(original, nil) if canonical_application_type?(original, rules)
        parens = original.scan(PAREN).map { |p| p[1..-2].strip }
        body = compact(original.gsub(PAREN, ""))

        found = rules.fetch("tokens").select { |t| body.match?(Regexp.new(t["pattern"])) }.map { |t| t["name"] }
        # 괄호 안 내용이 토큰 이름과 정확히 같을 때만 토큰으로 인정한다(예: 요양급여(미지급보험급여)).
        parens.each do |inner|
          token = rules.fetch("tokens").find { |t| t["name"] == compact(inner) }
          found << token["name"] if token
        end
        return Result.new(rules.fetch("other"), original) if found.empty?

        order = rules.fetch("tokens").map { |t| t["name"] }
        value = (found.uniq).sort_by { |name| order.index(name) }.join("|")
        leftovers = parens.reject { |inner| order.include?(compact(inner)) }
        Result.new(value, leftovers.presence&.join("; "))
      end

      def work_type(value)
        categorize(value, RULES.fetch("work_type"), first_match: false)
      end

      def employment_type(value)
        categorize(value, RULES.fetch("employment_type"), first_match: true)
      end

      private

      def canonical_application_type?(text, rules)
        names = rules.fetch("tokens").map { |t| t["name"] } << rules.fetch("other")
        parts = text.split("|")
        order = names.each_with_index.to_h
        parts.all? { |p| order.key?(p) } && parts == parts.uniq.sort_by { |p| order[p] }
      end

      def clean(value)
        value.to_s.unicode_normalize(:nfkc).gsub(/[[:space:]​‌‍﻿]/, "")
      end

      def compact(text)
        text.to_s.unicode_normalize(:nfkc).gsub(/[[:space:]]/, "")
      end

      # first_match: false → 목록 우선순위, true → 본문에서 가장 먼저 나오는 키워드.
      # 범주 키워드만 있는 값(띄어쓰기·어순·"근무/제/직" 차이)은 detail을 괄호 내용만 남기고,
      # 그 밖의 문구가 섞인 값은 원문 전체를 detail에 보존한다.
      def categorize(value, rules, first_match:)
        original = blank_to_nil(value) or return BLANK
        # 이미 표준 범주인 값은 그대로 둔다(재실행해도 detail이 지워지거나 바뀌지 않게).
        names = rules.fetch("categories").map { |c| c["name"] } << rules.fetch("other")
        return Result.new(original, nil) if names.include?(original)

        parens = original.scan(PAREN).map { |p| p[1..-2].strip }.reject(&:empty?)
        body = compact(original.gsub(PAREN, ""))
        category = pick(body, rules.fetch("categories"), first_match)
        return Result.new(rules.fetch("other"), original) unless category

        pure = pure_phrase?(body, category)
        detail = pure ? parens.presence&.join("; ") : original
        Result.new(category["name"], detail)
      end

      def pick(body, categories, first_match)
        return categories.find { |c| body.match?(Regexp.new(c["pattern"])) } unless first_match

        categories.filter_map { |c| (m = Regexp.new(c["pattern"]).match(body)) && [ m.begin(0), -m[0].size, c ] }
          .min_by { |pos, neg_len, _| [ pos, neg_len ] }&.last
      end

      def pure_phrase?(body, category)
        core = category["core"] or return false
        stripped = body.gsub(/고정|근무|근로자|근로|직|제|형/, "")
        stripped.match?(/\A(#{core})\z/)
      end
    end
  end
end
