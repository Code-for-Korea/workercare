# frozen_string_literal: true

# 산재알아보기 화면용 도우미. 문구는 config/locales/self_care_form.*.yml, 단계·허용값은 SelfCareForm::Flow.
module SelfCareFormHelper
  def self_care_title
    t("self_care_form.title")
  end

  def step_title(step, answers)
    key = step.to_s
    key = "title_prevention" if key == "body_part" && answers["situation"] == "prevention"
    key = "title" unless key == "title_prevention"
    t("self_care_form.steps.#{step}.#{key}")
  end

  def page_title_for_step(step, answers)
    t("self_care_form.question_title", n: SelfCareForm::Flow.question_number(step), total: SelfCareForm::Flow.question_count,
      title: step_title(step, answers)) + " — " + self_care_title
  end

  def back_path_for(step)
    target = SelfCareForm::Flow.previous_step(step)
    target == "start" ? self_care_form_start_path : (target == "profile" ? self_care_form_step_path("profile") : self_care_form_step_path(target))
  end

  def result_title(answers)
    t(answers["situation"] == "prevention" ? "self_care_form.result.title_prevention" : "self_care_form.result.title")
  end

  def dropped_labels(dropped)
    dropped.map { |d| t("self_care_form.result.dropped_#{d}") }.join(", ")
  end

  # 검색 결과의 신체부위는 좌우 구분을 떼고 앞의 셋까지만 보여 준다.
  def short_body_parts(parts)
    parts.map { |p| p.sub(/\A(우측|좌측|양측)\s+/, "") }.uniq.first(3).join("·")
  end

  def decision_text(answers)
    key = answers["decision"]
    key.present? ? SelfCareForm::Flow.decision_label(key) : t("self_care_form.review.not_chosen")
  end

  def situation_text(answers)
    SelfCareForm::Flow.situation_label(answers["situation"]) || t("self_care_form.review.not_chosen")
  end

  def choice_text(answers, key)
    if answers[key].present?
      answers[key]
    elsif answers["#{key}_text"].present?
      t("self_care_form.review.typed", text: answers["#{key}_text"])
    else
      t("self_care_form.review.not_chosen")
    end
  end

  def profile_text(answers, field)
    answers[field].presence || t("self_care_form.review.no_answer")
  end
end
