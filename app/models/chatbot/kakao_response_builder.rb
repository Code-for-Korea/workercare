# frozen_string_literal: true

module Chatbot
  # 카카오 스킬 응답(version 2.0) 생성. 항상 유효한 응답 본문을 만든다.
  #
  # 제한(skill_guide/answer_json_format.md): outputs 1~3개, quickReplies 10개 이하,
  # simpleText 1000자, listCard 항목 5개(말풍선 하나).
  # 사례는 listCard로 보여 준다. 요약 simpleText 1개 + listCard 최대 2개(5건씩) = outputs 3개라
  # 한 번에 10건(CaseSearch::PAGE_SIZE)이 한도다. 항목을 누르면 판정서 상세 페이지가 열린다.
  # 항목 제목은 '승인여부 · 신체부위 · 직업명', 설명은 신청인 주장이다.
  # 블록 ID가 아직 없으므로 바로연결은 action: "message"만 쓴다
  # (다음 블록에서 엔티티를 재추출하지 않으므로 조건은 extra로 이어간다).
  class KakaoResponseBuilder
    DISCLAIMER = "검색 결과는 개인의 산재 승인 가능성을 의미하지 않습니다."
    TEXT_LIMIT = 1000
    LIST_ITEMS_PER_CARD = 5
    # listCard 글자 수 규격(main_notions/setup_answer.md '말풍선 제작 스펙 정보', 모바일톡·공백 없는 한글 기준):
    # 헤더 15자, 타이틀(설명이 있을 때) 30자, 설명 16자. 공백·이모티콘이 있으면 덜 들어갈 수 있다.
    LIST_HEADER_LIMIT = 15
    LIST_ITEM_TITLE_LIMIT = 30
    LIST_ITEM_DESCRIPTION_LIMIT = 16
    ELLIPSIS = "…"
    SIDE_PREFIX = /\A(?:(?:우측|좌측|양측)\s*|(?:우|좌)\s+)/

    HOME_MESSAGE = "처음으로"
    REFINE_MESSAGE = "검색 조건 바꾸기"
    MORE_MESSAGE = "다른 사례 보기"

    class << self
      def results(search_result, conditions)
        first = search_result.page * CaseSearch::PAGE_SIZE + 1
        last = first + search_result.cases.size - 1
        count_text = if search_result.over_cap
          "검색 결과가 많아 정확한 건수는 표시하지 않습니다."
        else
          "총 #{search_result.total_count}건 중 #{first}~#{last}번째 사례입니다."
        end
        text = [ condition_summary(conditions), count_text, ignored_note(conditions), DISCLAIMER ].compact.join("\n\n")

        build(
          [ simple_text(text), *case_lists(search_result.cases, first) ],
          quick_replies(conditions, next_page: (search_result.page + 1 if search_result.has_more))
        )
      end

      def no_result(conditions)
        text = [
          "조건에 맞는 판정 사례를 찾지 못했습니다. 검색어를 바꾸거나 조건을 줄여보세요.\n(사례가 없다는 뜻이며, 승인 여부를 판단한 것은 아닙니다.)",
          condition_summary(conditions),
          ignored_note(conditions)
        ].compact.join("\n\n")
        build([ simple_text(text) ], quick_replies(conditions, next_page: nil))
      end

      def ask_conditions
        text = "찾고 싶은 사례의 질병명이나 직종, 작업 내용을 알려주세요.\n예) 회전근개파열, 물류 노동자 허리디스크\n\n이름·주민등록번호·전화번호 같은 개인정보는 입력하지 마세요."
        build([ simple_text(text) ], [ message_reply("처음으로", HOME_MESSAGE) ])
      end

      def error
        text = "일시적인 문제로 사례를 불러오지 못했습니다. 잠시 후 다시 시도해 주세요."
        build([ simple_text(text) ], [ message_reply("처음으로", HOME_MESSAGE) ])
      end

      private

      def build(outputs, quick_replies)
        { version: "2.0", template: { outputs: outputs, quickReplies: quick_replies } }
      end

      def simple_text(text)
        { simpleText: { text: text.truncate(TEXT_LIMIT) } }
      end

      # 사례를 5건씩 listCard 한 장으로 묶는다. first는 이 응답의 첫 사례 번호(1부터).
      def case_lists(cases, first)
        cases.each_slice(LIST_ITEMS_PER_CARD).with_index.map do |slice, index|
          from = first + index * LIST_ITEMS_PER_CARD
          to = from + slice.size - 1
          title = from == to ? "#{from}번째 사례" : "#{from}~#{to}번째 사례"
          { listCard: { header: { title: title.truncate(LIST_HEADER_LIMIT) }, items: slice.map { |c| list_item(c) } } }
        end
      end

      def list_item(public_case)
        {
          title: list_title(public_case),
          description: list_description(public_case),
          link: { web: public_case.detail_url }
        }
      end

      # 제목 = 승인여부 · 신체부위 · 직업명. 판정 결과를 맨 앞에 둬서 길어서 잘려도 핵심이 남는다.
      # 신체부위와 직업이 모두 없으면 제목이 판정 결과뿐이라 질병명으로 보완한다.
      def list_title(public_case)
        parts = [ public_case.result_label, body_part_label(public_case), public_case.job_name.presence ].compact
        parts << public_case.disease_name if parts.size == 1 && public_case.disease_name.present?
        fit_title(parts)
      end

      # 앞에서부터 " · "로 이어 붙이다가 제한을 넘는 항목은 남은 자리에 맞춰 줄이고 멈춘다.
      def fit_title(parts)
        title = parts.first.to_s
        parts.drop(1).each do |part|
          room = LIST_ITEM_TITLE_LIMIT - title.length - 3
          break if room < 2

          title = "#{title} · #{ellipsize(part, room)}"
          break if part.length > room
        end
        ellipsize(title, LIST_ITEM_TITLE_LIMIT)
      end

      # 부담 신체 부위는 파이프로 이어진 값이다. 좌우 구분은 떼고 중복을 합쳐 앞의 둘만 보여 준다.
      def body_part_label(public_case)
        public_case.burden_body_part
          .map { |part| part.sub(SIDE_PREFIX, "").strip }
          .reject(&:blank?).uniq.first(2).join(",").presence
      end

      # 설명 = 신청인 주장(글자 수가 허용하는 만큼). 주장이 없으면 출처 표시로 사건번호를 보인다.
      def list_description(public_case)
        text = public_case.claim_summary.presence || public_case.case_no.to_s
        ellipsize(text, LIST_ITEM_DESCRIPTION_LIMIT)
      end

      # limit자(말줄임 포함)로 줄인다. 말줄임표 앞에 공백이 남지 않게 한다.
      def ellipsize(text, limit)
        text.truncate(limit, omission: ELLIPSIS).sub(/\s+#{ELLIPSIS}\z/, ELLIPSIS)
      end

      def quick_replies(conditions, next_page:)
        replies = []
        replies << message_reply("다른 사례 보기", MORE_MESSAGE, conditions.to_extra.merge("page" => next_page)) if next_page
        replies << message_reply("조건 바꾸기", REFINE_MESSAGE, conditions.to_extra)
        replies << message_reply("처음으로", HOME_MESSAGE)
        replies
      end

      def message_reply(label, message_text, extra = nil)
        reply = { action: "message", label: label, messageText: message_text }
        reply[:extra] = extra if extra.present?
        reply
      end

      def condition_summary(conditions)
        parts = []
        parts << "질병 #{conditions.disease_name}" if conditions.disease_name.present?
        parts << "직종 #{conditions.job_name}" if conditions.job_name.present?
        parts << "작업 #{conditions.work_factor}" if conditions.work_factor.present?
        parts << "판정 #{PublicCase::RESULT_LABELS[conditions.result]}" if conditions.result.present?
        parts.empty? ? nil : "검색 조건: #{parts.join(' · ')}"
      end

      def ignored_note(conditions)
        return nil if conditions.ignored.blank?

        "판정 결과 조건은 인식하지 못해 제외했습니다. (인정·불인정·일부인정·변경인정 중에서 입력해 주세요.)" if conditions.ignored.include?("decision_type")
      end
    end
  end
end
