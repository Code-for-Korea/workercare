# frozen_string_literal: true

module SolarExtraction
  module Tasks
    # 추출 과제의 공통 부분: 입력 만들기, 프롬프트, 로컬 검증.
    #
    # 입력은 medical_records·recognized_facts·committee_decision 세 컬럼만 쓴다(이름 붙인 절로 이어 붙임).
    # 입력 원문에는 PIIMasking을 돌리지 않는다. 근거 문장이 원문과 글자 그대로 맞는지 확인해야 하기 때문이다.
    #
    # 로컬 검증: 스키마가 형태를 보장해도 값은 믿지 않는다(structured-outputs.md).
    # - enum·mention 값, 길이, 필수 조합을 확인한다.
    # - evidence_quote는 입력 텍스트의 부분 문자열이어야 한다. 비교는 유니코드 NFC 정규화 후 연속 공백(개행 포함)을
    #   한 칸으로 줄인 문자열끼리 한다(모델이 줄바꿈·공백을 바꿔 옮기는 것을 허용). 그 밖의 차이(말줄임표, 요약)는 틀린 것으로 본다.
    # - 검증에 실패한 근거 문장도 PIIMasking을 거치고 QUOTE_MAX자로 잘라 남긴다(모델 출력이 원문 그대로 저장되지 않게).
    # - 통과한 근거 문장에는 PIIMasking(번호 형태만 가림)을 검증 뒤에 적용해 저장한다. 검증 전에 가리면 원문과 달라져
    #   부분 문자열 검사가 깨지고, 검증 뒤에 가리면 결과 파일에 주민번호·전화번호·이메일·계좌 형태가 남지 않는다.
    #   이름·주소는 걸러지지 않으므로 결과 파일은 판정서와 같은 취급(저장소 밖, 외부 공유 금지)이다.
    class Base
      Validation = Data.define(:errors, :output)

      MENTIONS = %w[있음 없음 언급없음].freeze
      QUOTE_MAX = 80
      SECTIONS = {
        "medical_records" => "의학적 소견",
        "recognized_facts" => "인정 사실",
        "committee_decision" => "위원회 판단"
      }.freeze
      INPUT_COLUMNS = SECTIONS.keys.freeze

      def name = self.class::NAME
      def prompt_version = self.class::PROMPT_VERSION
      def schema_version = self.class::SCHEMA_VERSION

      # 이름 붙인 절로 이어 붙인 입력. 세 컬럼이 모두 비면 nil.
      def build_input(record)
        parts = SECTIONS.filter_map do |column, label|
          text = record[column].to_s.strip
          "[#{label}]\n#{text}" if text.present?
        end
        parts.join("\n\n").presence
      end

      def messages(input_text)
        [
          { role: "system", content: system_prompt },
          { role: "user", content: user_prompt(input_text) }
        ]
      end

      # 템플릿과 스키마가 차지하는 글자 수(입력 토큰 추정의 고정 부분)
      def overhead_chars
        system_prompt.length + user_prompt("").length + JSON.generate(json_schema).length
      end

      def schema_name = name

      def self.normalize_text(text)
        text.to_s.unicode_normalize(:nfc).gsub(/[[:space:]]+/, " ").strip
      end

      private

      COMMON_RULES = <<~TEXT
        규칙:
        - 아래 판정서 발췌에 적힌 사실만 추출합니다. 추측·일반 상식으로 채우지 않습니다.
        - 산재 승인 여부나 가능성을 예측하거나 평가하지 않습니다.
        - 판정서에 언급이 없으면 mention을 "언급없음"으로 하고 evidence_quote는 빈 문자열로 둡니다.
        - 판정서가 명시적으로 부정하면(예: "흡연력 없음") mention을 "없음"으로 하고 그 문장을 근거로 답니다. "없음"과 "언급없음"을 구분합니다.
        - 판정서에 적혀 있으면 mention을 "있음"으로 합니다.
        - evidence_quote는 판정서 발췌에서 글자 그대로 복사한 한 구절(80자 이하)이어야 합니다. 바꿔 쓰거나 요약하거나 말줄임표를 쓰지 않습니다.
        - 사업장 이름·개인 이름은 추출하지 않습니다.
      TEXT

      def user_prompt(input_text)
        "다음은 근로복지공단 업무상질병 판정서의 발췌입니다.\n\n#{input_text}\n\n위 내용에서 지정된 JSON 스키마대로 추출하세요."
      end

      def field_schema(value_schema)
        {
          type: "object",
          properties: {
            value: value_schema,
            evidence_quote: { type: "string" },
            mention: { type: "string", enum: MENTIONS }
          },
          required: %w[value evidence_quote mention],
          additionalProperties: false
        }
      end

      def normalize(text) = self.class.normalize_text(text)

      def mask(quote) = PIIMasking.mask(quote, log: false)

      # evidence_quote 공통 검사. 문자열이면 통과·실패와 상관없이 PIIMasking을 거친 뒤 QUOTE_MAX자로 자른 문장을 돌려준다
      # (검증에 실패한 모델 출력이 원문 그대로 저장되지 않게). 문자열이 아니면 nil.
      def check_quote(quote, mention, path, errors, haystack, required: nil)
        required = mention != "언급없음" if required.nil?
        unless quote.is_a?(String)
          errors << "#{path}: evidence_quote가 문자열이 아닙니다"
          return nil
        end
        if quote.length > QUOTE_MAX
          errors << "#{path}: evidence_quote가 #{QUOTE_MAX}자를 넘습니다(#{quote.length}자)"
        end
        if quote.strip.empty?
          errors << "#{path}: evidence_quote가 비어 있습니다" if required
          return safe_quote(quote)
        end
        errors << "#{path}: 언급없음인데 evidence_quote가 있습니다" if mention == "언급없음"
        errors << "#{path}: evidence_quote가 입력에 없습니다" unless haystack.include?(normalize(quote))
        safe_quote(quote)
      end

      def safe_quote(quote) = mask(quote)[0, QUOTE_MAX]

      # {value, evidence_quote, mention} 필드를 검사한다. value_check는 (value, mention) -> 오류 문자열 배열.
      def check_field(output, key, errors, haystack, &value_check)
        field = output[key]
        unless field.is_a?(Hash)
          errors << "#{key}: 객체가 아닙니다"
          return nil
        end
        extra = field.keys - %w[value evidence_quote mention]
        missing = %w[value evidence_quote mention] - field.keys
        errors << "#{key}: 키가 맞지 않습니다(추가 #{extra.size}, 누락 #{missing.size})" if extra.any? || missing.any?
        mention = field["mention"]
        unless MENTIONS.include?(mention)
          errors << "#{key}: mention 값이 허용 목록에 없습니다"
          return nil
        end
        value_check.call(field["value"], mention).each { |message| errors << "#{key}: #{message}" }
        quote = check_quote(field["evidence_quote"], mention, key, errors, haystack)
        { "value" => field["value"], "evidence_quote" => quote, "mention" => mention }
      end

      def check_keys(output, keys, errors)
        extra = output.keys - keys
        missing = keys - output.keys
        errors << "최상위 키가 맞지 않습니다(추가 #{extra.size}, 누락 #{missing.size})" if extra.any? || missing.any?
      end
    end
  end
end
