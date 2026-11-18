# frozen_string_literal: true

module SolarExtraction
  module Tasks
    # 과거 근무경력(plan 2.1): careers[] {start_ym, end_ym, occupation(KSCO 대분류), task, evidence_quote}, mention.
    # prior_career_months는 모델에게 받지 않고(산술 오류가 잦았다) 검증 때 careers 구간에서 코드로 계산해 결과에 넣는다.
    # - 구간마다 start_ym~end_ym을 양 끝 포함 월 수로 센다(2005-03~2005-03은 1개월). 겹치는 달은 한 번만 센다(월 집합 합집합).
    # - 시작·끝이 없는 구간이 하나라도 있으면 합계를 믿을 수 없어 nil. mention=없음이면 0, 언급없음이면 nil.
    # - careers가 MAX_CAREERS개를 넘으면 앞에서부터 MAX_CAREERS개만 남긴다(오류로 보지 않는다. 출력 잘림 방지용).
    # 사업장명은 비식별 처리돼 있어 추출하지 않는다. 현 직장 근속은 job_tenure_months가 따로 있으니 "입사 전" 경력만 받는다.
    class PriorCareer < Base
      NAME = "prior_career"
      PROMPT_VERSION = "prior_career-p2"
      SCHEMA_VERSION = "prior_career-s2"

      OCCUPATIONS = [
        "1 관리자", "2 전문가 및 관련 종사자", "3 사무 종사자", "4 서비스 종사자", "5 판매 종사자",
        "6 농림어업 숙련 종사자", "7 기능원 및 관련 기능 종사자", "8 장치·기계조작 및 조립 종사자", "9 단순노무 종사자", "미상"
      ].freeze
      TASK_MAX = 40
      MAX_CAREERS = 10
      MAX_TOKENS = 3000
      YM = /\A(\d{4})-(0[1-9]|1[0-2])\z/
      KEYS = %w[mention careers].freeze
      CAREER_KEYS = %w[start_ym end_ym occupation task evidence_quote].freeze

      def max_tokens = MAX_TOKENS

      def json_schema
        {
          type: "object",
          properties: {
            mention: { type: "string", enum: MENTIONS },
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
          핵심 규칙: "과거 근무경력"은 재해자가 현재 사업장(질병을 신청한 재해 당시 사업장)에 입사하기 전에 다닌 다른 직장의 이력입니다. 현재 사업장의 근무기간·업무는 과거 경력에 넣지 않습니다. 같은 사업장에서 업무나 고용형태만 바뀐 경우도 과거 경력이 아닙니다.

          필드:
          - mention:
            - 입사 전 다른 직장의 근무이력이 적혀 있으면 "있음"(careers에 1개 이상).
            - 판정서가 이전 경력이 없다고 적었으면("이전 근무경력: 무", "없음", "경력 없음") "없음"이고 careers는 빈 배열입니다.
            - 이전 경력에 대한 언급이 없으면 "언급없음"이고 careers는 빈 배열입니다.
            - 이전 경력이 없는데 현재 사업장 기록만 있다면 "없음"/"언급없음"으로 하고 현재 사업장을 careers에 넣지 않습니다.
          - careers: 과거 직장별 항목 배열(최대 #{MAX_CAREERS}개, 오래된 순). "있음"일 때만 채웁니다.
            - start_ym, end_ym: "YYYY-MM" 형식. 월을 알 수 없거나 적혀 있지 않으면 null. 연도만 있으면 null로 둡니다(월을 지어내지 않습니다).
            - occupation: 한국표준직업분류 대분류 중 하나(#{OCCUPATIONS.join(' / ')}). 판단할 수 없으면 "미상".
            - task: 한 일(#{TASK_MAX}자 이하). 판정서의 표현을 짧게 옮깁니다.
            - evidence_quote: 그 항목의 근거 구절(80자 이하, 글자 그대로 복사).
          - 합계 개월 수는 계산하지 않습니다(출력에 넣지 않습니다).
          - 사업장(회사) 이름은 추출하지 않습니다.

          예시(가상의 문장이며 형식 설명용입니다):
          - "입사 전 근무이력: 2001.3.~2004.2. 가 업체 용접, 2004.3.~2008.1. 나 업체 배관. 2008.2.부터 현 사업장 근무" -> mention "있음", careers는 앞의 두 구간만(현 사업장 2008.2.부터는 제외).
          - "이전 근무경력: 무. 2010.5.부터 현 사업장에서 근무" -> mention "없음", careers [].
          - 현 사업장 근무 내용만 있고 이전 직장 이야기가 없으면 -> mention "언급없음", careers [].
        TEXT
      end

      def validate(output, input_text)
        return Validation.new([ "출력이 객체가 아닙니다" ], nil) unless output.is_a?(Hash)

        errors = []
        check_keys(output, KEYS, errors)
        mention = output["mention"]
        errors << "mention 값이 허용 목록에 없습니다" unless MENTIONS.include?(mention)
        careers = check_careers(output["careers"], mention, normalize(input_text), errors)
        Validation.new(errors, { "mention" => mention, "prior_career_months" => compute_months(mention, careers), "careers" => careers })
      end

      # 구간 합계 개월 수(양 끝 포함, 겹침은 한 번만). 계산할 수 없으면 nil. 클래스 설명 참고.
      def compute_months(mention, careers)
        return 0 if mention == "없음"
        return nil unless mention == "있음" && careers.any?

        months = Set.new
        careers.each do |career|
          start_ym = career["start_ym"]
          end_ym = career["end_ym"]
          return nil if start_ym.nil? || end_ym.nil? || start_ym > end_ym

          (month_index(start_ym)..month_index(end_ym)).each { |index| months << index }
        end
        months.size
      end

      private

      def month_index(ym)
        year, month = ym.split("-").map(&:to_i)
        (year * 12) + month
      end

      def check_careers(careers, mention, haystack, errors)
        unless careers.is_a?(Array)
          errors << "careers가 배열이 아닙니다"
          return []
        end
        errors << "mention=#{mention}인데 careers가 있습니다" if mention != "있음" && careers.any?
        errors << "mention=있음인데 careers가 비어 있습니다" if mention == "있음" && careers.empty?
        careers.first(MAX_CAREERS).each_with_index.map { |career, index| check_career(career, "careers[#{index}]", haystack, errors) }.compact
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
        career.merge("start_ym" => start_ym, "end_ym" => end_ym, "evidence_quote" => quote)
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
