# frozen_string_literal: true

module Chatbot
  # 카카오 스킬 응답(version 2.0) 생성. 항상 유효한 응답 본문을 만든다.
  #
  # 제한(skill_guide/answer_json_format.md): outputs 1~3개, quickReplies 10개 이하,
  # simpleText 1000자, textCard title 50자 / description 128자(캐로셀), 버튼 label 14자.
  # basicCard는 썸네일이 필수라 textCard를 쓴다. 블록 ID가 아직 없으므로 바로연결은
  # action: "message"만 쓴다(다음 블록에서 엔티티를 재추출하지 않으므로 조건은 extra로 이어간다).
  class KakaoResponseBuilder
    DISCLAIMER = "검색 결과는 개인의 산재 승인 가능성을 의미하지 않습니다."
    TEXT_LIMIT = 1000
    CARD_TITLE_LIMIT = 50
    CARD_DESCRIPTION_LIMIT = 128
    BUTTON_LABEL_LIMIT = 14

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
          [ simple_text(text), case_carousel(search_result.cases) ],
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

      def case_carousel(cases)
        { carousel: { type: "textCard", items: cases.map { |c| case_card(c) } } }
      end

      def case_card(public_case)
        lines = []
        lines << "직종: #{public_case.job_name}" if public_case.job_name.present?
        lines << "근무기간: #{public_case.tenure_months}개월" if public_case.tenure_months.present?
        lines << "사건번호: #{public_case.case_no}"
        {
          title: "#{public_case.disease_name} · #{public_case.result_label}".truncate(CARD_TITLE_LIMIT),
          description: lines.join("\n").truncate(CARD_DESCRIPTION_LIMIT),
          buttons: [
            { action: "webLink", label: "판정서 보기".truncate(BUTTON_LABEL_LIMIT), webLinkUrl: public_case.detail_url }
          ]
        }
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
