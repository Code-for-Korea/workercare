# frozen_string_literal: true

module SolarExtraction
  module Tasks
    # 기저질환(plan 2.1): comorbidities(다중 enum), smoking, alcohol, 기왕증 출처(source).
    class Comorbidity < Base
      NAME = "comorbidity"
      PROMPT_VERSION = "comorbidity-p2"
      SCHEMA_VERSION = "comorbidity-s2"

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
          - smoking: 흡연 상태(#{SMOKING.join('/')}). 현재 흡연 중이거나 흡연량·흡연력이 적혀 있으면 "현재", 끊었다고 적혀 있으면 "과거", 비흡연이라고 적혀 있으면 "비흡연"(mention=없음). 언급이 없으면 "미확인"(mention=언급없음).
          - alcohol: 음주 상태(#{ALCOHOL.join('/')}). 음주 사실·음주량이 적혀 있으면 "음주", 음주하지 않는다고 적혀 있으면 "비음주"(mention=없음). 언급이 없으면 "미확인"(mention=언급없음).
          - source: 기저질환·기왕증이 어디에 근거해 적혔는지. 의학적 소견·인정 사실에 기록된 사실이면 "사실 기록", 위원회가 판단문에서 기왕증·퇴행성 등을 언급하면 "위원회 판단". 기저질환 언급이 없으면 "언급없음".

        값·mention·근거 일치 규칙(반드시 지킵니다):
        - 값이 "미확인"(또는 빈 배열, source "언급없음")이면 mention은 "언급없음"이고 evidence_quote는 빈 문자열입니다. 값이 미확인인데 mention을 "있음"으로 하거나 근거를 달지 않습니다.
        - mention이 "있음"이면 값은 "미확인"이 아니고(빈 배열도 아님) evidence_quote가 있어야 합니다. 흡연량·흡연력 문장이 있으면 smoking은 "미확인"이 아니라 "현재" 또는 "과거"입니다.
        - evidence_quote는 그 값을 직접 뒷받침하는 문장이어야 합니다. 진단명 머리말(예: "알콜성간질환"), "건강보험 수진내역" 같은 일반 구절, 다른 항목의 문장은 근거가 아닙니다. 직접 뒷받침하는 문장이 없으면 "미확인"/"언급없음"으로 둡니다.
        - 오래된 건강검진 문진표(재해보다 몇 년 전 시점)의 흡연·음주 응답은 지금의 상태로 읽지 않습니다. 시점이 현재라고 적혀 있지 않으면 "과거" 또는 "미확인"으로 합니다.
        - 기저질환은 과거력·복용 약물·검진 소견·진료내역 항목을 모두 훑어 중복 없이 나열합니다. 다만 약물 이름만 있고 질환명이 없으면 질환으로 추정하지 않습니다(보수적으로). 질환명이 적혀 있거나 "당뇨약", "혈압약"처럼 질환이 명시된 표현일 때만 해당 범주로 넣습니다. 근거 문장은 질환명이나 약 이름이 든 구절입니다.
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
        else
          if value == negative then [ "mention=있음인데 값이 #{negative}입니다" ]
          elsif value == "미확인" then [ "mention=있음인데 값이 미확인입니다" ]
          else []
          end
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
