# frozen_string_literal: true

module SolarExtraction
  module Tasks
    # 과거 근무경력(plan 2.1): careers[] {start_ym, end_ym, occupation(KSCO 대분류), task, evidence_quote}, prior_career_months, mention.
    # 사업장명은 비식별 처리돼 있어 추출하지 않는다. 현 직장 근속은 job_tenure_months가 따로 있으니 "입사 전" 경력만 받는다.
    class PriorCareer < Base
      NAME = "prior_career"
      PROMPT_VERSION = "prior_career-p1"
      SCHEMA_VERSION = "prior_career-s1"

      OCCUPATIONS = [
        "1 관리자", "2 전문가 및 관련 종사자", "3 사무 종사자", "4 서비스 종사자", "5 판매 종사자",
        "6 농림어업 숙련 종사자", "7 기능원 및 관련 기능 종사자", "8 장치·기계조작 및 조립 종사자", "9 단순노무 종사자", "미상"
      ].freeze
      TASK_MAX = 40
      MAX_CAREERS = 20
      MAX_MONTHS = 1200
      YM = /\A(\d{4})-(0[1-9]|1[0-2])\z/
      KEYS = %w[mention prior_career_months careers].freeze
      CAREER_KEYS = %w[start_ym end_ym occupation task evidence_quote].freeze

      def json_schema
        {
          type: "object",
          properties: {
            mention: { type: "string", enum: MENTIONS },
            prior_career_months: { type: [ "integer", "null" ] },
            careers: {
              type: "array",
              items: {
                type: "object",
                properties: {
                  start_ym: { type: [ "string", "null" ] },
                  end_ym: { type: [ "string", "null" ] },
                  occupation: { type: "string", enum: OCCUPATIONS },
                  task: { type: "string" },
                  evidence_quote: { type: "string" }
                },
                required: CAREER_KEYS,
                additionalProperties: false
              }
            }
          },
          required: KEYS,
          additionalProperties: false
        }
      end

      def system_prompt
        <<~TEXT
          당신은 산업재해 판정서에서 사실 정보를 추출하는 도구입니다. 한국어 판정서를 읽고 재해자의 과거(현 직장 입사 전) 근무경력을 JSON으로 추출합니다.

          #{COMMON_RULES}
          필드:
          - mention: 과거 근무경력(입사 전 근무이력·직업력)이 적혀 있으면 "있음", 없다고 명시되면 "없음", 언급이 없으면 "언급없음".
          - careers: 과거 직장별 항목 배열(최대 #{MAX_CAREERS}개). "있음"일 때만 채웁니다.
            - start_ym, end_ym: "YYYY-MM" 형식. 월을 알 수 없거나 적혀 있지 않으면 null. 연도만 있으면 null로 둡니다(월을 지어내지 않습니다).
            - occupation: 한국표준직업분류 대분류 중 하나(#{OCCUPATIONS.join(' / ')}). 판단할 수 없으면 "미상".
            - task: 한 일(#{TASK_MAX}자 이하). 판정서의 표현을 짧게 옮깁니다.
            - evidence_quote: 그 항목의 근거 구절(80자 이하, 글자 그대로 복사).
          - prior_career_months: 판정서가 과거 근무경력의 합계 기간을 개월 수로 직접 적었거나 항목 기간에서 명확히 합산되면 그 정수, 아니면 null.
          - 사업장(회사) 이름은 추출하지 않습니다.
        TEXT
      end

      def validate(output, input_text)
        return Validation.new([ "출력이 객체가 아닙니다" ], nil) unless output.is_a?(Hash)

        errors = []
        check_keys(output, KEYS, errors)
        mention = output["mention"]
        errors << "mention 값이 허용 목록에 없습니다" unless MENTIONS.include?(mention)
        months = check_months(output["prior_career_months"], mention, errors)
        careers = check_careers(output["careers"], mention, normalize(input_text), errors)
        Validation.new(errors, { "mention" => mention, "prior_career_months" => months, "careers" => careers })
      end

      private

      def check_months(months, mention, errors)
        return nil if months.nil?

        if !months.is_a?(Integer) || months.negative? || months > MAX_MONTHS
          errors << "prior_career_months가 0~#{MAX_MONTHS} 정수가 아닙니다"
        elsif mention == "언급없음" || mention == "없음"
          errors << "mention=#{mention}인데 prior_career_months가 있습니다"
        end
        months
      end

      def check_careers(careers, mention, haystack, errors)
        unless careers.is_a?(Array)
          errors << "careers가 배열이 아닙니다"
          return []
        end
        errors << "careers가 #{MAX_CAREERS}개를 넘습니다" if careers.size > MAX_CAREERS
        errors << "mention=#{mention}인데 careers가 있습니다" if mention != "있음" && careers.any?
        careers.each_with_index.map { |career, index| check_career(career, "careers[#{index}]", haystack, errors) }.compact
      end

      def check_career(career, path, haystack, errors)
        unless career.is_a?(Hash)
          errors << "#{path}: 객체가 아닙니다"
          return nil
        end
        errors << "#{path}: 키가 맞지 않습니다" if career.keys.sort != CAREER_KEYS.sort
        start_ym = check_ym(career["start_ym"], "#{path}.start_ym", errors)
        end_ym = check_ym(career["end_ym"], "#{path}.end_ym", errors)
        errors << "#{path}: 시작이 끝보다 늦습니다" if start_ym && end_ym && start_ym > end_ym
        errors << "#{path}: occupation이 허용 목록에 없습니다" unless OCCUPATIONS.include?(career["occupation"])
        task = career["task"]
        if !task.is_a?(String)
          errors << "#{path}: task가 문자열이 아닙니다"
        elsif task.length > TASK_MAX
          errors << "#{path}: task가 #{TASK_MAX}자를 넘습니다(#{task.length}자)"
        end
        quote = check_quote(career["evidence_quote"], "있음", path, errors, haystack)
        career.merge("evidence_quote" => quote)
      end

      def check_ym(value, path, errors)
        return nil if value.nil?

        unless value.is_a?(String) && YM.match?(value)
          errors << "#{path}: YYYY-MM 형식이 아닙니다"
          return nil
        end
        value
      end
    end
  end
end
