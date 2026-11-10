# frozen_string_literal: true

require "net/http"

module SelfCareForm
  # 사용자가 선택 동의한 경우에만, 고른 옵션의 라벨을 구글 폼의 formResponse 주소로 한 번 보낸다.
  # 구글의 공식 API가 아니라 폼 제출 주소에 `entry.<id>=값`을 POST하는 방식이라 구글이 막을 수 있다(미확인).
  #
  # - 서버가 호출하므로 구글은 우리 서버의 IP와 요청 메타데이터를 본다. 우리는 IP·User-Agent·세션 ID·신체부위 자유 입력을
  #   폼 필드로 보내지 않는다. 직업 자유 입력은 사전 직종 이름 또는 가린 입력(30자)을 보낸다.
  # - 구글은 필수 문항이 빠져도 200을 주고 조용히 버린다. 그래서 200을 성공으로 단정하지 않고 "요청을 보냈다"로만
  #   취급한다. 폼의 모든 문항은 단답형·필수 아님이어야 한다.
  # - 실패(타임아웃·예외·비 2xx)는 사용자 화면에 영향을 주지 않고, 내용 없이 예외 클래스·상태 코드만 로그에 남긴다.
  class GoogleFormSubmitter
    TIMEOUT = 1 # 열기·읽기 각 1초
    TEST_PREFIX = "[테스트]"

    Outcome = Data.define(:sent, :status, :error)

    # transport: ->(uri, form_params) { Net::HTTPResponse }, http: Net::HTTP.start를 가진 클래스(테스트에서 바꿔 끼운다)
    def initialize(settings: Settings.current, transport: nil, logger: Rails.logger, http: Net::HTTP)
      @settings = settings
      @http = http
      @transport = transport || self.class.transport || method(:post)
      @logger = logger
    end

    # 보낼 폼 파라미터: SENDABLE_KEYS ∩ entries 키 중 값이 있는 것만. 건너뛴 항목은 보내지 않는다.
    def form_params(values)
      values.each_with_object({}) do |(key, value), params|
        entry = @settings.entries[key.to_s]
        next if entry.blank? || value.blank?

        params["entry.#{entry}"] = value.to_s
      end
    end

    # @return [Outcome] 실패해도 예외를 던지지 않는다.
    def submit(values)
      return Outcome.new(sent: false, status: nil, error: "disabled") unless @settings.valid?

      params = form_params(values)
      return Outcome.new(sent: false, status: nil, error: "no_params") if params.empty?

      response = @transport.call(@settings.uri, params)
      status = response.code.to_i
      @logger.info("[self_care_form] 구글 폼 전송 요청을 보냈습니다 (status=#{status})")
      @logger.warn("[self_care_form] 구글 폼이 2xx가 아닌 상태를 돌려줬습니다 (status=#{status})") unless status.between?(200, 299)
      Outcome.new(sent: true, status: status, error: nil)
    rescue StandardError => e
      @logger.warn("[self_care_form] 구글 폼 전송 실패 (#{e.class})")
      Outcome.new(sent: false, status: nil, error: e.class.name)
    end

    # 응답과 예외 처리를 모두 이 클래스가 하므로 transport는 요청만 보낸다. 리다이렉트는 따라가지 않는다.
    def post(uri, params)
      request = Net::HTTP::Post.new(uri)
      request.set_form_data(params)
      @http.start(uri.host, uri.port, use_ssl: true, open_timeout: TIMEOUT, read_timeout: TIMEOUT) do |http|
        http.request(request)
      end
    end

    class << self
      # 테스트에서 컨트롤러가 만드는 인스턴스의 전송을 바꿔 끼운다(nil이면 실제 Net::HTTP).
      attr_accessor :transport

      # 답(Answers)에서 보낼 값을 만든다. 신체부위의 직접 입력 원문은 넣지 않는다.
      #   body_part: 버튼으로 고른 개념 또는 직접 입력에서 사전이 찾은 개념 이름(원문 아님)
      #   job: 버튼으로 고른 직종 이름. 직접 입력은 사전 직종 이름, 못 찾으면 입력한 말(번호 형태 가림, 30자 이내).
      #        "모르겠어요"는 그 라벨(2026-11-11 사용자 결정)
      #   decision: "모두 보기"를 눌렀으면 보내고 건너뛰었으면 보내지 않는다
      #   relaxed·result_count: result(CaseFinder::Result)가 있을 때만
      def values_for(answers, result: nil)
        conditions = answers.search_conditions
        values = {
          "body_part" => answers["body_part"].presence || (conditions.body_concept if answers["body_part_text"].present?),
          "job" => job_value(answers),
          "decision" => (Flow.decision_label(answers["decision"]) if answers["decision"].present?),
          "situation" => Flow.situation_label(answers["situation"])
        }
        Flow::PROFILE_FIELDS.each_key { |field| values[field] = answers[field].presence }
        if result
          values["relaxed"] = result.dropped.any? ? "예(#{result.dropped.map { |d| d == :job ? '직업' : '판정 결과' }.join(', ')})" : "아니오"
          values["result_count"] = result.over_cap ? "500 이상" : result.total_count.to_s
        end
        values.compact
      end

      # 직업 값. 직접 입력(job_text)은 사전 직종 이름을 우선 보내고, 못 찾으면 입력한 말을 가려서 보낸다.
      def job_value(answers)
        if answers["job_text"].present?
          typed_job_value(answers["job_text"])
        elsif answers["job"].present?
          answers["job"]
        elsif answers["job_unknown"].present?
          I18n.t("self_care_form.unknown")
        end
      end

      def typed_job_value(text)
        match = JobMatcher.call(text)
        return match.concept if match

        PIIMasking.mask(text.to_s.gsub(/[[:space:]]+/, " ").strip).to_s.strip.slice(0, Flow::FREE_TEXT_MAX).presence
      end

      # send_test용: 모든 값을 [테스트]로 시작하게 만든다.
      def test_values(keys)
        keys.index_with { |key| "#{TEST_PREFIX} #{key}" }
      end
    end
  end
end
