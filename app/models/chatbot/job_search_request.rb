# frozen_string_literal: true

module Chatbot
  # 직종 검색 스킬의 요청을 해석한다.
  #
  # 선택 상태는 서버에 저장하지 않고 버튼·항목의 extra(clientExtra)로 이어 간다.
  #   keyword  검색어(정리된 값) / selected  선택한 직종 이름들 / pick  이번에 누른 직종 / page  후보 쪽
  #
  # 검색어를 얻는 순서:
  #   1. clientExtra의 keyword (선택·쪽 이동 같은 후속 요청)
  #   2. action.params의 keyword (블록 파라미터로 넘긴 값, 스킬 테스트)
  #   3. userRequest.utterance — 입력 대기 컨텍스트(job_kw)가 살아 있을 때만. 폴백 블록처럼
  #      아무 발화나 들어올 수 있는 자리에 연결해도 엉뚱한 문장을 검색어로 쓰지 않는다.
  # 발화 원문을 읽는 곳은 여기뿐이고, 로그에는 남기지 않는다.
  class JobSearchRequest
    KEYWORD_CONTEXT = "job_kw"
    MAX_SELECTED = 10
    MAX_PAGE = 19
    MAX_NAME_LENGTH = 30

    def initialize(payload)
      @payload = payload.is_a?(Hash) ? payload : {}
    end

    # [정리된 검색어, 출처(:extra/:param/:utterance)]. 없으면 [nil, :none].
    def keyword_with_source
      @keyword_with_source ||= begin
        if (value = JobKeyword.clean(client_extra["keyword"]))
          [ value, :extra ]
        elsif (value = JobKeyword.clean(fetch_path("action", "params", "keyword")))
          [ value, :param ]
        elsif awaiting_keyword? && (value = JobKeyword.clean(fetch_path("userRequest", "utterance")))
          [ value, :utterance ]
        else
          [ nil, :none ]
        end
      end
    end

    def keyword = keyword_with_source.first
    def source = keyword_with_source.last

    def page
      @page ||= client_extra["page"].to_i.clamp(0, MAX_PAGE)
    end

    # 이번 요청으로 갱신된 선택 목록. pick이 이미 선택돼 있으면 빼고(토글), 아니면 더한다.
    def selected
      @selected ||= begin
        list = names(client_extra["selected"])
        pick = clean_name(client_extra["pick"])
        if pick
          if list.any? { |name| same?(name, pick) }
            list.reject! { |name| same?(name, pick) }
          elsif list.size < MAX_SELECTED
            list << pick
          else
            @cap_reached = true
          end
        end
        list
      end
    end

    def cap_reached?
      selected
      @cap_reached == true
    end

    private

    def awaiting_keyword?
      contexts = @payload["contexts"]
      contexts.is_a?(Array) && contexts.any? { |context| context.is_a?(Hash) && context["name"] == KEYWORD_CONTEXT }
    end

    def names(value)
      Array(value).filter_map { |name| clean_name(name) }.uniq { |name| squash(name) }.first(MAX_SELECTED)
    end

    def clean_name(value)
      return nil unless value.is_a?(String)

      text = value.strip.truncate(MAX_NAME_LENGTH, omission: "").presence
      text unless text&.start_with?("#", "$")
    end

    def same?(left, right) = squash(left) == squash(right)
    def squash(text) = text.to_s.gsub(/\s+/, "")

    def client_extra
      extra = fetch_path("action", "clientExtra")
      extra.is_a?(Hash) ? extra : {}
    end

    def fetch_path(*keys)
      keys.reduce(@payload) { |node, key| node.is_a?(Hash) ? node[key] : (return nil) }
    end
  end
end
