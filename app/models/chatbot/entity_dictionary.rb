# frozen_string_literal: true

module Chatbot
  # config/chatbot/entities/<엔티티>.yml의 개념(대표 엔트리) → db 표기 목록.
  #
  # 카카오는 사용자가 어떤 동의어를 말해도 서버에 **대표 엔트리**를 보낸다. 서버가 그 대표를
  # 사전의 db 표기들로 확장해 검색하도록(신체부위 토큰, 직종 핵심어) 사전을 읽는 공용 모듈이다.
  # 사전 파일은 배포 이미지에 들어 있고 한 번 읽은 뒤 메모리에 둔다.
  module EntityDictionary
    class << self
      # { 공백 없는 대표 엔트리 => [db 표기, ...] }
      def db_by_concept(entity)
        cache[entity] ||= load_dictionary(entity)
      end

      def normalize(text)
        text.to_s.gsub(/\s+/, "")
      end

      def reset!
        @cache = nil
      end

      private

      def cache
        @cache ||= {}
      end

      def load_dictionary(entity)
        path = EntityBuilder.config_path(entity)
        return {} unless path.exist?

        YAML.safe_load_file(path).fetch("concepts", {}).to_h do |name, body|
          [ normalize(name), Array(body["db"]).map(&:to_s) ]
        end
      end
    end
  end
end
