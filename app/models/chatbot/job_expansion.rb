# frozen_string_literal: true

module Chatbot
  # 직종 엔티티의 대표 엔트리를 사전의 핵심어(db)들로 확장한다.
  #
  # 카카오는 사용자가 `조리`라고 말해도 대표 엔트리 `조리원`을 보낸다. 그 글자 그대로 찾으면
  # `조리사`·`주방 보조`가 후보에서 빠진다. 사전(config/chatbot/entities/job_name.yml)에서
  # `조리원` → `조리·주방·급식·음식서비스·음식관련`으로 넓혀 찾는다.
  module JobExpansion
    class << self
      # 대표 엔트리면 핵심어 목록, 사전에 없는 값이면 nil(호출한 쪽이 일반 검색어로 처리한다).
      def stems_for(label)
        key = EntityDictionary.normalize(label)
        return nil if key.empty?

        EntityDictionary.db_by_concept("job_name")[key].presence
      end
    end
  end
end
