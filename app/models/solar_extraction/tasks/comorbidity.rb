# frozen_string_literal: true

module SolarExtraction
  module Tasks
    # 기저질환(plan 2.1): comorbidities(다중 enum), smoking, alcohol, 기왕증 출처(source).
    #
    # source는 모델에게 받지 않고(p3에서 따로 내게 했더니 기저질환을 놓칠 때마다 같이 틀렸다) 코드가 comorbidities와 입력 절에서 파생한다
    # (CODEBOOK 결정 2026-11-20: 기저질환 칸에서 파생). 규칙:
    # - comorbidities가 비면 `언급없음`.
    # - 근거 문장이 [의학적 소견]·[인정 사실]에 글자 그대로 있거나, 값에 든 범주(기타 제외)의 키워드가 그 두 절에 있으면 `사실 기록`
    #   (위원회가 그 소견을 인용해도 사실 기록).
    # - 그렇지 않고 [위원회 판단]에만 있으면 `위원회 판단`.
    # - 한계: 단일 근거 문장과 키워드 사전으로 가르는 간이 규칙이다. 신청 상병명의 키워드(협착 등)가 소견 절에 있어 `사실 기록`으로
    #   잘못 가를 수 있고, 근거를 못 찾으면(검증 실패) 가장 흔한 `사실 기록`으로 둔다. 기타만 있고 근거가 두 절에 모두 없으면 같다.
    # 근거-키워드 검사(v4)는 comorbidities는 오류가 아니라 output["review_flags"]로 낮췄다(p3 정답 200건에서 거르는 효과보다 과잉 차단이 컸다).
    # 흡연·음주 키워드 검사와 일반 머리말 검사는 그대로 invalid다.
    class Comorbidity < Base
      NAME = "comorbidity"
      PROMPT_VERSION = "comorbidity-p4"
      SCHEMA_VERSION = "comorbidity-s3"
      VALIDATOR_VERSION = "comorbidity-v4"

      COMORBIDITIES = %w[고혈압 당뇨 이상지질 비만 퇴행성 심장질환 뇌혈관 기타].freeze
      SMOKING = %w[현재 과거 비흡연 미확인].freeze
      ALCOHOL = %w[음주 비음주 미확인].freeze
      SOURCE = %w[사실\ 기록 위원회\ 판단 언급없음].freeze # 파생 값의 허용 목록(모델 출력이 아니다)
      KEYS = %w[comorbidities smoking alcohol].freeze
      FACT_SECTIONS = %w[medical_records recognized_facts].freeze

      # 근거 문장-값 키워드 검증(v3). 근거 문장에 값과 관련된 키워드가 하나도 없으면 invalid.
      # 목록은 일부러 보수적이다(진짜 근거를 막는 것보다 일부 엉뚱한 근거를 놓치는 쪽이 낫다). 영문은 대소문자를 가리지 않는다.
      # comorbidities는 목록 전체에 근거 문장이 하나뿐이라 값에 든 범주 중 하나라도 키워드가 있으면 통과한다("기타"는 아래 일반 구절 검사만).
      COMORBIDITY_KEYWORDS = {
        "고혈압" => [ /혈압/, /(?<![A-Za-z])HTN(?![A-Za-z])/i ],
        "당뇨" => [ /당뇨/, /혈당/, /인슐린/, /(?<![A-Za-z])DM(?![A-Za-z])/i, /HbA1c/i, /당화혈색소/ ],
        "이상지질" => [ /고지혈/, /이상지질/, /콜레스테롤/, /중성지방/, /(?<![A-Za-z])LDL/i ],
        "비만" => [ /비만/, /(?<![A-Za-z])BMI(?![A-Za-z])/i, /체질량/ ],
        "퇴행성" => [ /퇴행/, /퇴변/, /변성/, /골극/, /협착/, /골관절염/,
                   /degenerat/i, /osteophyte/i, /sclerosis/i, /spondylo/i, /osteoarthr/i, /arthrosis/i, /stenosis/i, /\bOA\b/ ],
        "심장질환" => [ /심근/, /협심/, /부정맥/, /심부전/, /관상/, /심방세동/ ],
        "뇌혈관" => [ /뇌경색/, /뇌출혈/, /뇌내출혈/, /뇌졸중/, /뇌혈관/, /지주막하/, /뇌동맥/, /(?<![A-Za-z])CVA(?![A-Za-z])/, /infarct/i, /stroke/i ]
      }.freeze
      SMOKING_KEYWORDS = [ /흡연/, /담배/, /금연/, /끽연/, /연초/, /피우|피웠/, /개비/, /(?:\d|반|한)\s*갑(?!상)/, /pack/i ].freeze
      # 알콜성·알코올성 + 질환명("알콜성간질환", "알코올성 지방간")은 진단명이지 음주 사실이 아니므로 키워드 검사 전에 지운다.
      ALCOHOL_DIAGNOSIS = /알(?:콜|코올)성[가-힣]*/
      # 술은 "수술·기술·시술"에 들어 있어 앞에 한글이 없을 때만 센다.
      ALCOHOL_KEYWORDS = [ /음주/, /(?<![가-힣])술/, /주량/, /소주/, /맥주/, /막걸리/, /양주/, /폭음|과음/, /금주/, /알코올|알콜/ ].freeze
      # 이것만 남으면(지운 뒤 한글·숫자가 2자 미만) 일반 머리말이라 근거가 아니다. 공백은 무시하고 비교한다.
      GENERIC_PHRASES = %w[건강보험공단수진내역 건강보험수진내역 수진내역 진료내역 기타및상세불명의 상세불명의 상세불명 과거력 병력 진단명 상병명 상병].freeze
      GENERIC_MIN_CHARS = 2

      def json_schema
        {
          type: "object",
          properties: {
            comorbidities: field_schema({ type: "array", items: { type: "string", enum: COMORBIDITIES } }),
            smoking: field_schema({ type: "string", enum: SMOKING }),
            alcohol: field_schema({ type: "string", enum: ALCOHOL })
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

          comorbidities 범주 정의(해당하는 범주만 넣고, 신청한 상병 자체는 넣지 않습니다):
          - 신청 상병(재해자가 산재로 신청한 병명) 자체는 넣지 않습니다. 이전에 따로 앓은 같은 질환이라고 적혀 있을 때만 넣습니다. 신청 상병과 같은 부위의 과거 치료도 판정서가 "기왕증"·"개인 기존질환"이라 명시하지 않으면 넣지 않습니다.
          - 고혈압·당뇨·이상지질·심장질환: 진단명이나 "혈압약"·"당뇨약"·"고지혈증약"처럼 질환이 명시된 치료 이력이 있을 때 넣습니다. 건강검진의 "의심"·"주의"·"정상B"·"유질환 의심" 등급은 기저질환이 아닙니다. 위원회가 진단으로 서술하면 인정합니다.
          - 비만: 판정서에 "비만"이라 적혔거나 BMI·체질량지수가 비만 기준(25 이상)이라고 적혀 있을 때 넣습니다.
          - 뇌혈관: 뇌경색·뇌출혈·뇌졸중 등 뇌혈관질환의 진단·치료 이력이 있을 때 넣습니다(뇌 영상의 단순 소견어는 제외).
          - 퇴행성: 판정서가 대상자의 병변·소견을 퇴행성·퇴행·퇴변·변성·골극·골관절염·협착(소견으로서)·degenerative·osteophyte·spondylosis 등으로 적었으면, 주치의·자문의·특진·위원회 누가 적었든 넣습니다. 위원회가 "퇴행성 변화가 영향을 미쳤을 개연성"처럼 논증 문장에서 병변을 퇴행성이라 일컬어도 넣습니다. 그러나 신청 상병명 문자열에 "퇴행성"이 들어 있을 뿐이거나 사업주의 주장일 뿐이면 넣지 않습니다.
          - 기타: 위 범주에 맞지 않는 기왕증·기존 질환(예: 갑상선·간·신장질환, 신청 상병과 다른 계통의 진료 이력)을 판정서가 대상자의 기저질환·기왕증으로 적었을 때 넣습니다. 신청 상병이나 신청 상병과 같은 부위의 치료 이력만 있으면 넣지 않습니다.
          - 출처(source) 같은 다른 필드는 출력하지 않습니다.

        값·mention·근거 일치 규칙(반드시 지킵니다):
        - 값이 "미확인"(또는 빈 배열, source "언급없음")이면 mention은 "언급없음"이고 evidence_quote는 빈 문자열입니다. 값이 미확인인데 mention을 "있음"으로 하거나 근거를 달지 않습니다.
        - mention이 "있음"이면 값은 "미확인"이 아니고(빈 배열도 아님) evidence_quote가 있어야 합니다. 흡연량·흡연력 문장이 있으면 smoking은 "미확인"이 아니라 "현재" 또는 "과거"입니다.
        - evidence_quote는 그 값을 직접 뒷받침하는 문장이어야 합니다. 진단명 머리말(예: "알콜성간질환"), "건강보험 수진내역" 같은 일반 구절, 다른 항목의 문장은 근거가 아닙니다. 직접 뒷받침하는 문장이 없으면 "미확인"/"언급없음"으로 둡니다.
        - 오래된 건강검진 문진표(재해보다 몇 년 전 시점)의 흡연·음주 응답은 지금의 상태로 읽지 않습니다. 시점이 현재라고 적혀 있지 않으면 "과거" 또는 "미확인"으로 합니다.
        - 합성 예시(형식 설명용): "과거력: 고혈압, 당뇨 약 복용 중" -> comorbidities ["고혈압","당뇨"]. 신청 상병이 요추 추간판탈출증이고 소견에 "요추 퇴행성 변화"가 있으면 "퇴행성". 신청 상병명만 "퇴행성 관절염"이고 판정서에 소견 서술이 없으면 퇴행성이 아닙니다(빈 배열).
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
        flags = check_evidence_support(output, errors)
        cleaned["source"] = derive_source(cleaned["comorbidities"], input_text)
        cleaned["review_flags"] = flags
        Validation.new(errors, cleaned.compact)
      end

      private

      # 값을 뒷받침하는 키워드가 근거 문장에 있는지 확인한다. 이미 다른 검사로 막힌 경우(값이 미확인·언급없음, 근거 비어 있음, 객체 아님)는 건너뛴다.
      # comorbidities의 키워드 부재는 오류 대신 review_flags({rule, field, message})로 돌려준다. 나머지는 errors에 넣는다.
      def check_evidence_support(output, errors)
        flags = []
        KEYS.each do |key|
          field = output[key]
          next unless field.is_a?(Hash) && field["mention"] != "언급없음" && field["evidence_quote"].is_a?(String)

          quote = normalize(field["evidence_quote"])
          next if quote.empty? || UNSET_VALUES.include?(field["value"])

          if generic_only?(quote)
            errors << "#{key}: evidence_quote가 일반 머리말뿐이라 값의 근거가 아닙니다"
          elsif !supported?(key, field["value"], quote)
            message = "#{key}: evidence_quote에 값(#{Array(field['value']).join(', ')})의 키워드가 없습니다"
            if key == "comorbidities"
              flags << { "rule" => "evidence_keyword_missing", "field" => key, "message" => message }
            else
              errors << message
            end
          end
        end
        flags
      end

      # 근거 위치와 키워드로 기왕증 출처를 파생한다(클래스 설명 참고). 반환은 {value, evidence_quote, mention} 모양이다.
      def derive_source(field, input_text)
        categories = field.is_a?(Hash) ? Array(field["value"]) & COMORBIDITIES : []
        value = categories.empty? ? "언급없음" : source_value(field, categories, input_text)
        { "value" => value, "evidence_quote" => "", "mention" => value == "언급없음" ? "언급없음" : "있음" }
      end

      def source_value(field, categories, input_text)
        sections = split_sections(input_text)
        facts = FACT_SECTIONS.map { |column| sections[column] }.compact.join(" ")
        committee = sections["committee_decision"].to_s
        quote = normalize(field["evidence_quote"])
        patterns = categories.reject { |category| category == "기타" }.flat_map { |category| COMORBIDITY_KEYWORDS.fetch(category) }
        return "사실 기록" if quote.present? && facts.include?(quote)
        return "사실 기록" if patterns.any? { |pattern| pattern.match?(facts) }
        return "위원회 판단" if (quote.present? && committee.include?(quote)) || patterns.any? { |pattern| pattern.match?(committee) }

        "사실 기록"
      end

      def generic_only?(quote)
        rest = quote.gsub(/[[:space:]]/, "")
        GENERIC_PHRASES.each { |phrase| rest = rest.gsub(phrase, "") }
        rest.gsub(/[^가-힣A-Za-z0-9]/, "").length < GENERIC_MIN_CHARS
      end

      def supported?(key, value, quote)
        case key
        when "comorbidities"
          categories = Array(value) & COMORBIDITIES
          return true if categories.empty? || categories.include?("기타")

          categories.any? { |category| COMORBIDITY_KEYWORDS.fetch(category).any? { |pattern| pattern.match?(quote) } }
        when "smoking" then SMOKING_KEYWORDS.any? { |pattern| pattern.match?(quote) }
        when "alcohol"
          stripped = quote.gsub(ALCOHOL_DIAGNOSIS, " ")
          ALCOHOL_KEYWORDS.any? { |pattern| pattern.match?(stripped) }
        else true # source는 일반 머리말 검사만(근거 문장의 종류를 키워드로 가를 수 없다)
        end
      end

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
    end
  end
end
