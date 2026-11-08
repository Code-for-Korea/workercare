# 산재알아보기: 단계별로 고르고(세션 쿠키에만 보관) 고른 조건으로 비슷한 판정 사례를 보여 준다.
# 문서: docs/self-care-form.md. 서버 DB에는 아무것도 저장하지 않는다.
class SelfCareFormController < ApplicationController
  before_action :require_consent, except: %i[start agree]
  before_action :set_step, only: %i[show update]

  # GET /self-care-form — 소개와 동의
  def start
    @consent_error = false
  end

  # POST /self-care-form — 필수 동의를 확인하고 시작한다
  def agree
    if params[:consent] == "1"
      session[:self_care_form_consent] = true
      session[:self_care_form] ||= {}
      redirect_to self_care_form_step_path("situation")
    else
      @consent_error = true
      render :start, status: :unprocessable_entity
    end
  end

  # GET /self-care-form/:step
  def show
    @answers = answers
    render :step
  end

  # POST /self-care-form/:step — 답을 검증해 세션에 담고 다음 단계로 간다
  def update
    current = answers
    skip = answer_params[:skip_to_review].present?
    skip ? current.skip_profile : current.apply(@step, answer_params)
    session[:self_care_form] = current.to_h

    redirect_to(skip ? self_care_form_review_path : next_path(@step))
  end

  # GET /self-care-form/review — 고른 내용을 확인한다
  def review
    @answers = answers
  end

  # GET /self-care-form/result — 고른 조건으로 사례를 찾는다
  def result
    @answers = answers
    @conditions = @answers.search_conditions
    @result = SelfCareForm::CaseFinder.new(@conditions).call
    @cases = @result.records.map { |record| Chatbot::PublicCase.new(record) }
    @search_link_params = search_link_params(@result.conditions)
  end

  # POST /self-care-form/reset — 답을 비우고 처음부터 다시 시작한다(제출 표시는 남긴다)
  def reset
    session.delete(:self_care_form)
    session.delete(:self_care_form_consent)
    redirect_to self_care_form_start_path
  end

  private

  def answers
    SelfCareForm::Answers.from_session(session[:self_care_form])
  end

  def answer_params
    params.permit(:value, :free_text, :skip_to_review, *SelfCareForm::Answers::PROFILE_KEYS)
  end

  def set_step
    @step = params[:step].to_s
  end

  def next_path(step)
    target = SelfCareForm::Flow.next_step(step)
    target == "review" ? self_care_form_review_path : self_care_form_step_path(target)
  end

  # 세션 쿠키가 사라진 경우(브라우저를 닫음·쿠키 차단)에는 조용히 시작 화면으로 보내지 않고 이유를 알려 준다.
  def require_consent
    return if session[:self_care_form_consent]

    @session_lost = true
    @consent_error = false
    render :start
  end

  # "더 자세히 찾기" 링크: 결과를 낸 시도의 조건 중 버튼으로 고른 값(펼친 신체부위 토큰·직종 핵심어·판정 결과)만 넘긴다.
  # 직접 입력한 직업 원문과 통계 답은 넘기지 않는다.
  def search_link_params(conditions)
    {
      burden_body_part: conditions.body_tokens.presence,
      job_name_any: conditions.job_name_any.presence,
      result: conditions.decision.presence
    }.compact
  end
end
