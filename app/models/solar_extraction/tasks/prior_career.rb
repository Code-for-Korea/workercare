# frozen_string_literal: true

module SolarExtraction
  module Tasks
    # 과거 근무경력(plan 2.1): careers[] {start_ym, end_ym, occupation(KSCO 대분류), task, evidence_quote}, mention.
    # prior_career_months는 모델에게 받지 않고(산술 오류가 잦았다) 검증 때 careers 구간에서 코드로 계산해 결과에 넣는다.
    # - 구간마다 start_ym~end_ym을 양 끝 포함 월 수로 센다(2005-03~2005-03은 1개월). 겹치는 달은 한 번만 센다(월 집합 합집합).
    # - 시작·끝이 없는 구간이 하나라도 있으면 합계를 믿을 수 없어 nil. mention=없음이면 0, 언급없음이면 nil.
    # - careers가 MAX_CAREERS개를 넘으면 앞에서부터 MAX_CAREERS개만 남긴다(오류로 보지 않는다. 출력 잘림 방지용).
    #
    # 현 사업장 후처리(v3). 프롬프트로 막지 못한 "현 사업장 경력 혼입"을 코드로 점검한다.
    # - invalid(오류): (a) 종료 시점(end_ym)이 없고 근거 문장이 진행 중으로 읽히는 구간("현재", "재직 중", "진단일까지" 등). 과거 경력은 끝났어야 한다.
    # - review_flags(오류 아님, 결과 output["review_flags"]에 항상 배열로 남김): 어림짐작이 섞인 의심.
    #   b) 입력 텍스트가 현 사업장 시작일을 밝혔고("현 사업장"·"재해 당시 사업장" + 날짜는 가장 이른 날짜, "입사" + 날짜는 가장 늦은 날짜)
    #      구간이 그 날 이후에 시작하거나 걸쳐 있음. c) 근거 문장에 고용형태 변경 표지(정규직·계약직·일용·프리랜서·월급제·전환)가
    #      있고 같은 문장에 둘 이상이거나 "같은 업체"와 함께 나오거나, 이어지는 구간들이 서로 다른 고용형태임(같은 업체 안의 고용형태 변경 의심).
    #   형식: {"rule", "career_indexes"(careers 배열 위치), "message"}. 규칙 이름은 ongoing 외에 RULES 참고.
    # 이 점검은 입력 텍스트와 careers만 쓴다(DB의 다른 컬럼·job_tenure_months는 읽지 않는다).
    # 사업장명은 비식별 처리돼 있어 추출하지 않는다. 현 직장 근속은 job_tenure_months가 따로 있으니 "입사 전" 경력만 받는다.
    class PriorCareer < Base
      NAME = "prior_career"
      PROMPT_VERSION = "prior_career-p2"
      SCHEMA_VERSION = "prior_career-s2"
      VALIDATOR_VERSION = "prior_career-v3"

      OCCUPATIONS = [
        "1 관리자", "2 전문가 및 관련 종사자", "3 사무 종사자", "4 서비스 종사자", "5 판매 종사자",
        "6 농림어업 숙련 종사자", "7 기능원 및 관련 기능 종사자", "8 장치·기계조작 및 조립 종사자", "9 단순노무 종사자", "미상"
      ].freeze
      TASK_MAX = 40
      MAX_CAREERS = 10
      MAX_TOKENS = 3000
      YM = /\A(\d{4})-(0[1-9]|1[0-2])\z/
      KEYS = %w[mention careers].freeze
      # 진행 중 표현("현재", "재직 중", "근무 중"). 종료 시점이 없는 구간의 근거에서만 본다.
      ONGOING = /현재(?!\s*(?:사업장|회사|직장))|재직\s*중|근무\s*중|진단일\s*까지|재해일\s*까지/
      SAME_WORKPLACE = /같은\s*(?:업체|사업장|회사)/
      CURRENT_EMPLOYER = /현\s*사업장|현재\s*사업장|재해\s*당시\s*사업장|당해\s*사업장|재해\s*발생\s*사업장/
      JOINED = /입사(?!\s*(?:전|이전))/ # "입사 전 근무이력"은 머리말이라 제외
      DATE = /(\d{4})\s*(?:[.\-\/]|년)\s*(\d{1,2})/
      DATE_WINDOW = 20
      EMPLOYMENT_TYPES = {
        "정규직" => /정규직/, "계약직" => /계약직/, "일용" => /일용/, "프리랜서" => /프리랜서|프리랜스/, "월급제" => /월급제/
      }.freeze
      CONVERSION = /전환/
      RULES = %w[starts_after_current_start overlaps_current_start employment_type_change].freeze
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
        flags = review_flags(careers, normalize(input_text))
        Validation.new(errors, { "mention" => mention, "prior_career_months" => compute_months(mention, careers), "careers" => careers, "review_flags" => flags })
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

      # 오류가 아닌 의심 표시. 검증에 실패한 구간(careers에서 빠진 항목)은 없으므로 위치는 careers 배열 기준이다.
      def review_flags(careers, haystack)
        flags = []
        cutoff, strong = current_start(haystack)
        careers.each_with_index do |career, index|
          start_ym = career["start_ym"]
          end_ym = career["end_ym"]
          next unless cutoff && start_ym

          if start_ym > cutoff || (strong && start_ym == cutoff)
            flags << flag("starts_after_current_start", [ index ], "구간이 현 사업장 시작(#{cutoff}) 이후에 시작합니다")
          elsif end_ym && end_ym > cutoff
            flags << flag("overlaps_current_start", [ index ], "구간이 현 사업장 시작(#{cutoff})과 겹칩니다")
          end
        end
        flags + employment_type_flags(careers)
      end

      def flag(rule, indexes, message) = { "rule" => rule, "career_indexes" => indexes, "message" => message }

      # 입력이 밝힌 현 사업장 시작 연월과 그것이 확실한 표지에서 나왔는지. 못 찾으면 nil.
      def current_start(haystack)
        strong = dates_near(haystack, CURRENT_EMPLOYER).min
        return [ strong, true ] if strong

        joined = dates_near(haystack, JOINED).max
        joined ? [ joined, false ] : nil
      end

      # 표지 앞뒤 DATE_WINDOW자 안에서 표지에 가장 가까운 날짜 하나씩(표지마다)을 "YYYY-MM"으로 모은다.
      def dates_near(text, marker)
        text.to_enum(:scan, marker).filter_map do
          at = Regexp.last_match.begin(0)
          from = [ at - DATE_WINDOW, 0 ].max
          window = text[from, (at - from) + DATE_WINDOW]
          dates = window.to_enum(:scan, DATE).map { [ Regexp.last_match.begin(0) + from, ym_string(Regexp.last_match(1), Regexp.last_match(2)) ] }
          dates.min_by { |position, _| (position - at).abs }&.last
        end.compact
      end

      def ym_string(year, month)
        number = month.to_i
        return nil unless number.between?(1, 12)

        format("%<year>04d-%<month>02d", year: year.to_i, month: number)
      end

      def employment_types(quote)
        EMPLOYMENT_TYPES.select { |_, pattern| pattern.match?(quote.to_s) }.keys
      end

      def employment_type_flags(careers)
        flags = []
        types = careers.map { |career| employment_types(career["evidence_quote"]) }
        careers.each_with_index do |career, index|
          quote = career["evidence_quote"].to_s
          if CONVERSION.match?(quote) || types[index].size >= 2 || (types[index].any? && SAME_WORKPLACE.match?(quote))
            flags << flag("employment_type_change", [ index ], "근거 문장에 고용형태 변경 표지가 있습니다")
          end
        end
        ordered = careers.each_index.sort_by { |index| careers[index]["start_ym"].to_s }
        ordered.each_cons(2) do |a, b|
          next if types[a].empty? || types[b].empty? || types[a] == types[b]
          next unless contiguous?(careers[a]["end_ym"], careers[b]["start_ym"])

          flags << flag("employment_type_change", [ a, b ], "이어지는 구간의 고용형태가 다릅니다(같은 업체 내 변경 의심)")
        end
        flags
      end

      # 앞 구간 끝과 뒤 구간 시작이 이어지거나(같은 달·다음 달), 어느 쪽이든 알 수 없으면 true.
      def contiguous?(end_ym, start_ym)
        return true if end_ym.nil? || start_ym.nil?

        month_index(start_ym) - month_index(end_ym) <= 1 && month_index(start_ym) >= month_index(end_ym)
      end

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
        if end_ym.nil? && quote.present? && ONGOING.match?(quote)
          errors << "#{path}: 종료 시점이 없고 근거 문장이 진행 중이라 현 사업장 경력으로 보입니다"
        end
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
