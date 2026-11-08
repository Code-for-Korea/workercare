# frozen_string_literal: true

# 산재 신청 방법 안내(신청 절차·필요 서류·불인정 대응·급여 종류·처리 기간).
# 본문은 config/apply_guide/procedure_guides.yml의 마크다운이고(MCP 제거 때 지운 config/locales/procedure_guides.yml을
# 되살린 것이다. 화면 문구용 I18n 파일이 아니므로 i18n-tasks가 번역 누락으로 세지 않게 locales 밖에 둔다), 출처·확인일은 파일 맨 위 주석
# (`# source:`, `# last_updated:`)에 있다. 화면(/apply-guide)과 마크다운(/apply-guide.md)이 같은 본문을 쓴다.
# 제도 안내이므로 출시 전에 공식 출처로 다시 확인한다. 새 사실 주장은 이 모듈에 쓰지 않는다.
module ApplyGuide
  PATH = Rails.root.join("config/apply_guide/procedure_guides.yml")
  TOPIC_KEYS = %w[application required_documents rejection_appeal compensation_types timeline].freeze
  DISCLAIMER = "이 안내는 참고용이며 최종 판단은 상담사와 법원이 합니다. 의료·법률 판단을 대신하지 않습니다."

  # markdown: 제목 줄(`## …`)을 뺀 본문
  Topic = Data.define(:key, :title, :markdown)

  class << self
    def topics
      @topics ||= TOPIC_KEYS.filter_map do |key|
        raw = guides[key]
        next if raw.blank?

        title, body = split_title(raw)
        Topic.new(key: key, title: title, markdown: body)
      end
    end

    def last_updated
      metadata["last_updated"]
    end

    def source
      metadata["source"]
    end

    # /apply-guide.md 본문
    def markdown
      lines = [ "# 산재 신청 방법 안내", "", "> #{DISCLAIMER}", "" ]
      topics.each { |t| lines << "## #{t.title}" << "" << t.markdown.strip << "" }
      lines << "---" << ""
      lines << "- 출처: #{source}" if source
      lines << "- 마지막 확인일: #{last_updated}" if last_updated
      lines << ""
      lines.join("\n")
    end

    def reset!
      @topics = @guides = @metadata = nil
    end

    private

    def guides
      @guides ||= YAML.safe_load_file(PATH).fetch("ko", {})
    rescue Errno::ENOENT
      {}
    end

    def metadata
      @metadata ||= File.read(PATH).scan(/^#\s*(last_updated|source):\s*(.+)$/).to_h { |k, v| [ k, v.strip ] }
    rescue Errno::ENOENT
      {}
    end

    # 첫 줄이 "## 제목"이면 제목과 나머지를 나눈다. 제목이 없으면 키로 대신한다.
    def split_title(raw)
      first, rest = raw.lstrip.split("\n", 2)
      if first.start_with?("## ")
        [ first.delete_prefix("## ").strip, rest.to_s.strip ]
      else
        [ nil, raw.strip ]
      end
    end
  end
end
