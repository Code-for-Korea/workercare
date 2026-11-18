# frozen_string_literal: true

module SolarExtraction
  module Tasks
    # 기저질환(plan 2.1): comorbidities(다중 enum), smoking, alcohol, 기왕증 출처(source).
    class Comorbidity < Base
      NAME = "comorbidity"
      PROMPT_VERSION = "comorbidity-p1"
      SCHEMA_VERSION = "comorbidity-s1"

      COMORBIDITIES = %w[고혈압 당뇨 이상지질 비만 퇴행성 심장질환 뇌혈관 기타].freeze
      SMOKING = %w[현재 과거 비흡연 미확인].freeze
      ALCOHOL = %w[음주 비음주 미확인].freeze
      SOURCE = %w[사실\ 기록 위원회\ 판단 언급없음].freeze
      KEYS = %w[comorbidities smoking alcohol source].freeze

      def json_schema
        {
          type: "object",
          properties: {
            comorbidities: field_schema({ type: "array", items: { type: "string", enum: COMORBIDITIES } }),
            smoking: field_schema({ type: "string", enum: SMOKING }),
            alcohol: field_schema({ type: "string", enum: ALCOHOL }),
            source: field_schema({ type: "string", enum: SOURCE })
          },
          required: KEYS,
          additionalProperties: false
        }
      end

      def system_prompt
        <<~TEXT
          당신은 산업재해 판정서에서 사실 정보를 추출하는 도구입니다. 한국어 판정서를 읽고 기저질환 정보를 JSON으로 추출합니다.

          #{COMMON_RULES}
          필드:
          - comorbidities: 재해자가 가진 것으로 판정서에 적힌 기저질환·기왕증 범주(#{COMORBIDITIES.join(', ')}). 언급이 없거나 없다고 명시되면 빈 배열.
          - smoking: 흡연 상태(#{SMOKING.join('/')}). 언급이 없으면 "미확인"(mention=언급없음), 비흡연이라고 적혀 있으면 "비흡연"(mention=없음).
          - alcohol: 음주 상태(#{ALCOHOL.join('/')}). 언급이 없으면 "미확인"(mention=언급없음), 음주하지 않는다고 적혀 있으면 "비음주"(mention=없음).
          - source: 기저질환·기왕증이 어디에 근거해 적혔는지. 의학적 소견·인정 사실에 기록된 사실이면 "사실 기록", 위원회가 판단문에서 기왕증·퇴행성 등을 언급하면 "위원회 판단". 기저질환 언급이 없으면 "언급없음".
        TEXT
      end

      # 규칙: 언급없음이면 빈 값(빈 배열, 미확인, 언급없음)이고 근거도 없다. 있음이면 근거 문장이 있다.
      def validate(output, input_text)
        return Validation.new([ "출력이 객체가 아닙니다" ], nil) unless output.is_a?(Hash)

        errors = []
        check_keys(output, KEYS, errors)
        haystack = normalize(input_text)
        cleaned = {}
        cleaned["comorbidities"] = check_field(output, "comorbidities", errors, haystack) { |value, mention| check_list(value, mention) }
        cleaned["smoking"] = check_field(output, "smoking", errors, haystack) { |value, mention| check_state(value, mention, SMOKING, "비흡연") }
        cleaned["alcohol"] = check_field(output, "alcohol", errors, haystack) { |value, mention| check_state(value, mention, ALCOHOL, "비음주") }
        cleaned["source"] = check_field(output, "source", errors, haystack) { |value, mention| check_source(value, mention) }
        Validation.new(errors, cleaned.compact)
      end

      private

      def check_list(value, mention)
        return [ "배열이 아닙니다" ] unless value.is_a?(Array)

        errors = []
        errors << "허용 목록에 없는 값이 있습니다" unless value.all? { |item| COMORBIDITIES.include?(item) }
        errors << "중복 값이 있습니다" if value.uniq.size != value.size
        errors << "mention=있음인데 비어 있습니다" if mention == "있음" && value.empty?
        errors << "mention=#{mention}인데 값이 있습니다" if mention != "있음" && value.any?
        errors
      end

      def check_state(value, mention, allowed, negative)
        return [ "허용 목록에 없는 값입니다" ] unless allowed.include?(value)

        case mention
        when "언급없음" then value == "미확인" ? [] : [ "언급없음인데 값이 미확인이 아닙니다" ]
        when "없음" then value == negative ? [] : [ "mention=없음인데 값이 #{negative}가 아닙니다" ]
        else value == negative ? [ "mention=있음인데 값이 #{negative}입니다" ] : []
        end
      end

      def check_source(value, mention)
        return [ "허용 목록에 없는 값입니다" ] unless SOURCE.include?(value)

        if mention == "있음"
          value == "언급없음" ? [ "mention=있음인데 값이 언급없음입니다" ] : []
        else
          value == "언급없음" ? [] : [ "mention=#{mention}인데 값이 #{value}입니다" ]
        end
      end
    end
  end
end
