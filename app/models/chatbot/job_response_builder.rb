# frozen_string_literal: true

module Chatbot
  # 직종 검색 스킬의 카카오 응답. 후보 직종을 listCard로 보여 주고, 항목을 누르면 선택에 더하거나 뺀다.
  #
  # 구성(outputs 최대 3개): 요약 simpleText + 후보 listCard 최대 2장(5개씩) = 한 쪽에 10개.
  # 선택 상태는 서버에 두지 않고 항목·버튼의 extra로 이어 간다(JobSearchRequest).
  # 항목은 action: "message"의 고정 문장(JOB_PICK_MESSAGE)을 보낸다. 직종 이름은 제각각이라
  # 블록 발화로 등록할 수 없어서, 고른 직종은 extra.pick에 싣는다.
  class JobResponseBuilder < KakaoResponseBuilder
    # class << self 안에서는 부모 클래스의 상수가 조회되지 않아 이 클래스 자리에 다시 선언한다.
    LIST_ITEMS_PER_CARD = KakaoResponseBuilder::LIST_ITEMS_PER_CARD
    LIST_HEADER_LIMIT = KakaoResponseBuilder::LIST_HEADER_LIMIT
    LIST_ITEM_TITLE_LIMIT = KakaoResponseBuilder::LIST_ITEM_TITLE_LIMIT
    LIST_ITEM_DESCRIPTION_LIMIT = KakaoResponseBuilder::LIST_ITEM_DESCRIPTION_LIMIT
    HOME_MESSAGE = KakaoResponseBuilder::HOME_MESSAGE

    JOB_START_MESSAGE = KakaoResponseBuilder::JOB_SEARCH_MESSAGE
    JOB_PICK_MESSAGE = "직종 선택"
    JOB_MORE_MESSAGE = "직종 더 보기"
    JOB_FIND_MESSAGE = "선택한 직종으로 찾기"
    PAGE_SIZE = 10
    EXAMPLE_KEYWORDS = %w[조리 용접 청소 경비 운전].freeze
    # 입력 대기 컨텍스트. 블록에 같은 이름의 출력 컨텍스트가 선언돼 있으면 다시 입력을 받을 수 있다.
    AWAIT_CONTEXT = { name: JobSearchRequest::KEYWORD_CONTEXT, lifeSpan: 1, ttl: 600 }.freeze

    class << self
      # 후보가 있을 때. candidates는 JobCandidates::Candidate 전체, page는 0부터.
      def candidates(keyword:, candidates:, page:, selected:, cap_reached: false)
        offset = page * PAGE_SIZE
        shown = candidates.drop(offset).first(PAGE_SIZE)
        selected_keys = selected.map { |name| squash(name) }

        lists = shown.each_slice(LIST_ITEMS_PER_CARD).with_index.map do |slice, index|
          from = offset + index * LIST_ITEMS_PER_CARD + 1
          to = from + slice.size - 1
          title = from == to ? "#{from}번째 직종" : "#{from}~#{to}번째 직종"
          { listCard: { header: { title: title.truncate(LIST_HEADER_LIMIT) },
                        items: slice.map { |candidate| item(candidate, keyword, selected, selected_keys, page) } } }
        end

        has_more = offset + shown.size < candidates.size
        build(
          [ simple_text(summary(keyword, candidates, offset, shown.size, selected, cap_reached)), *lists ],
          replies(keyword, selected, page, has_more),
          context: [ AWAIT_CONTEXT ]
        )
      end

      # 검색어가 없거나 너무 짧을 때. note는 앞에 붙이는 한 줄 안내.
      def prompt(note: nil)
        text = [ note, "찾고 싶은 직종을 입력해 주세요.\n예) 조리, 용접, 청소\n\n이름·주민등록번호·전화번호 같은 개인정보는 입력하지 마세요." ].compact.join("\n")
        build([ simple_text(text) ], example_replies + [ message_reply("처음으로", HOME_MESSAGE) ], context: [ AWAIT_CONTEXT ])
      end

      def no_match(keyword)
        text = "'#{keyword}'에 맞는 직종을 찾지 못했어요.\n다른 단어로 다시 입력해 주세요. 예) 조리, 용접, 청소"
        build([ simple_text(text) ], example_replies + [ message_reply("처음으로", HOME_MESSAGE) ], context: [ AWAIT_CONTEXT ])
      end

      private

      def item(candidate, keyword, selected, selected_keys, page)
        mark = selected_keys.include?(squash(candidate.name)) ? "✓ " : ""
        {
          title: ellipsize("#{mark}#{candidate.name}", LIST_ITEM_TITLE_LIMIT),
          description: ellipsize("#{candidate.count}건", LIST_ITEM_DESCRIPTION_LIMIT),
          action: "message",
          messageText: JOB_PICK_MESSAGE,
          extra: { "keyword" => keyword, "selected" => selected, "page" => page, "pick" => candidate.name }
        }
      end

      def summary(keyword, candidates, offset, shown_count, selected, cap_reached)
        from = offset + 1
        to = offset + shown_count
        total = candidates.size >= JobCandidates::FETCH_LIMIT ? "#{JobCandidates::FETCH_LIMIT}개 이상" : "#{candidates.size}개"
        lines = [ "'#{keyword}'#{eu_ro(keyword)} 찾은 직종 #{total} 중 #{from}~#{to}번째예요." ]
        lines << if selected.empty?
          "선택한 직종이 아직 없어요. 눌러서 추가하고, 다시 누르면 빼요."
        else
          "선택한 직종(#{selected.size}): #{selected.join(', ')}"
        end
        lines << "직종은 최대 #{JobSearchRequest::MAX_SELECTED}개까지 고를 수 있어요." if cap_reached
        lines.join("\n\n")
      end

      def replies(keyword, selected, page, has_more)
        replies = []
        replies << message_reply("선택한 직종으로 찾기", JOB_FIND_MESSAGE, { "job_names" => selected }) if selected.any?
        replies << message_reply("직종 더 보기", JOB_MORE_MESSAGE, { "keyword" => keyword, "selected" => selected, "page" => page + 1 }) if has_more
        replies << message_reply("이전 직종", JOB_MORE_MESSAGE, { "keyword" => keyword, "selected" => selected, "page" => page - 1 }) if page.positive?
        replies << message_reply("직종 다시 검색", JOB_START_MESSAGE)
        replies << message_reply("처음으로", HOME_MESSAGE)
        replies
      end

      def example_replies
        EXAMPLE_KEYWORDS.map { |word| message_reply(word, word) }
      end

      # 받침이 있으면 '으로', 없거나 ㄹ 받침이면 '로'. 한글이 아닌 끝글자는 '로'로 둔다.
      def eu_ro(word)
        last = word.to_s.strip[-1].to_s
        return "로" unless last.match?(/\A[가-힣]\z/)

        final = (last.ord - 0xAC00) % 28
        final.zero? || final == 8 ? "로" : "으로"
      end

      def squash(text)
        text.to_s.gsub(/\s+/, "")
      end
    end
  end
end
