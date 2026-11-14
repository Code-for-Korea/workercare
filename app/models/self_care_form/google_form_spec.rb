# frozen_string_literal: true

module SelfCareForm
  # 구글 폼에 만들 문항 목록(`rails self_care_form:google_form_spec`). 앱이 보낼 수 있는 키 전체(Flow::SENDABLE_KEYS)와
  # 현재 설정(entries)에 id가 있는지를 함께 보여 준다. 문항 제목은 앱이 보지 않고 entry id만 본다.
  module GoogleFormSpec
    TITLES = {
      "body_part" => "신체부위", "job" => "직종", "decision" => "판정결과", "age_band" => "연령대", "region" => "지역",
      "application_experience" => "산재신청경험", "respondent" => "누구의일", "situation" => "상황",
      "relaxed" => "조건완화여부", "result_count" => "결과건수"
    }.freeze

    class << self
      # 앱이 보내는 값의 형식(허용 라벨)
      def values_for(key)
        case key
        when "body_part" then "사전 개념 이름 (#{Flow.body_part_names.first(3).join(', ')}…)"
        when "job" then "대표 직종 이름 (#{Flow::JOB_NAMES.first(3).join(', ')}…)"
        when "decision" then Flow::DECISION_KEYS.map { |k| Flow.decision_label(k) }.join(" / ")
        when "situation" then Flow::SITUATIONS.values.join(" / ")
        when "relaxed" then "예(판정 결과, 직업) / 아니오"
        when "result_count" then "숫자 또는 \"500 이상\""
        else Flow::PROFILE_FIELDS.fetch(key).join(" / ")
        end
      end

      def render(settings)
        lines = [ "| 앱 키 | 문항 제목(예) | 보내는 값 | 현재 설정 |", "|---|---|---|---|" ]
        Flow::SENDABLE_KEYS.each do |key|
          present = settings.entries.key?(key) ? "있음(#{settings.entries[key]})" : "없음"
          lines << "| `#{key}` | #{TITLES.fetch(key)} | #{values_for(key)} | #{present} |"
        end
        lines.join("\n")
      end
    end
  end
end
