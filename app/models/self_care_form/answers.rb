# frozen_string_literal: true

module SelfCareForm
  # 암호화 세션 쿠키(session[:self_care_form])에 담는 단계별 답. 값은 모두 짧은 문자열이다.
  # 모든 입력은 Flow의 허용 목록으로 검증하고, 허용값 밖은 무시하거나 "답하지 않음"으로 처리한다.
  # 자유 입력(신체부위·직업)은 검색에만 쓰고 FREE_TEXT_MAX자로 자른다(쿠키 4KB 제한, 구글 폼으로 보내지 않음).
  class Answers
    PROFILE_KEYS = Flow::PROFILE_FIELDS.keys.freeze
    KEYS = (%w[situation body_part body_part_text job job_text decision] + PROFILE_KEYS).freeze
    SKIP = "skip"
    NONE = "none"

    Conditions = Data.define(:body_tokens, :body_concept, :body_unmatched, :job_name_any, :job_name, :decision)

    def self.from_session(value)
      new(value.is_a?(Hash) ? value : {})
    end

    def initialize(hash = {})
      @data = hash.to_h.stringify_keys.slice(*KEYS).transform_values { |v| v.to_s }
    end

    def to_h
      @data.dup
    end

    def [](key)
      @data[key.to_s]
    end

    # 한 단계의 입력을 반영한다. params는 ActionController::Parameters 또는 Hash(:value, :free_text, 프로필 키).
    def apply(step, params)
      params = params.to_h.with_indifferent_access if params.respond_to?(:to_h)
      case step.to_s
      when "situation" then apply_choice("situation", params[:value], Flow::SITUATIONS.keys)
      when "body_part" then apply_button_or_text("body_part", params, Flow.body_part_names)
      when "job" then apply_button_or_text("job", params, Flow::JOB_NAMES)
      when "decision" then apply_decision(params[:value])
      when "profile" then apply_profile(params)
      end
      self
    end

    def skip_profile
      PROFILE_KEYS.each { |key| @data.delete(key) }
      self
    end

    # 검색 조건. 직접 입력한 신체부위는 BodyPartMatcher로 사전 개념을 찾고, 못 찾으면 조건 없이 찾는다(body_unmatched).
    def search_conditions
      tokens = nil
      concept = nil
      unmatched = false
      if self["body_part"].present?
        concept = self["body_part"]
        tokens = Chatbot::BodyPartExpansion.tokens_for(concept)
      elsif self["body_part_text"].present?
        match = BodyPartMatcher.call(self["body_part_text"])
        if match
          concept = match.concept
          tokens = Chatbot::BodyPartExpansion.tokens_for(concept)
        else
          unmatched = true
        end
      end

      job_any = nil
      job_text = nil
      if self["job_text"].present?
        job_text = self["job_text"]
      elsif self["job"].present?
        stems = Chatbot::JobExpansion.stems_for(self["job"])
        stems ? job_any = stems : job_text = self["job"]
      end

      decision = self["decision"]
      decision = nil if decision.blank? || decision == Flow::DECISION_ALL

      Conditions.new(body_tokens: tokens, body_concept: concept, body_unmatched: unmatched,
        job_name_any: job_any, job_name: job_text, decision: decision)
    end

    private

    def apply_choice(key, value, allowed)
      if value.to_s == SKIP
        @data.delete(key)
      elsif allowed.include?(value.to_s)
        @data[key] = value.to_s
      end
    end

    def apply_button_or_text(key, params, names)
      text_key = "#{key}_text"
      value = params[:value].to_s
      free = params[:free_text].to_s.gsub(/[[:space:]]+/, " ").strip.slice(0, Flow::FREE_TEXT_MAX)
      if free.present?
        @data[text_key] = free
        @data.delete(key)
      elsif [ NONE, SKIP ].include?(value)
        @data.delete(key)
        @data.delete(text_key)
      elsif names.include?(value)
        @data[key] = value
        @data.delete(text_key)
      end
    end

    def apply_decision(value)
      value = value.to_s
      if value == SKIP
        @data.delete("decision")
      elsif Flow::DECISION_KEYS.include?(value)
        @data["decision"] = value
      end
    end

    def apply_profile(params)
      Flow::PROFILE_FIELDS.each do |field, options|
        value = params[field].to_s
        options.include?(value) ? @data[field] = value : @data.delete(field)
      end
    end
  end
end
