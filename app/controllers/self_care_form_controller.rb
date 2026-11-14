# 단계별 사례 찾기: 단계별로 고르고(세션 쿠키에만 보관) 고른 조건으로 비슷한 판정 사례를 보여 준다.
# 문서: docs/self-care-form.md. 서버 DB에는 아무것도 저장하지 않는다.
class SelfCareFormController < ApplicationController
  before_action :require_consent, except: %i[start agree summary]
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
      # 통계용 저장 동의는 구글 연동이 켜진 배포에서만 받는다(꺼져 있으면 체크란도 없다).
      session[:self_care_form_stats_consent] = (SelfCareForm.google_enabled? && params[:stats_consent] == "1") || nil
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

  # GET /self-care-form/summary — 결과 화면의 turbo-frame `case_summary`가 불러오는 "쉬운 요약". 항상 같은 프레임 id로
  # 응답한다(동의가 없거나 꺼져 있으면 빈 프레임). 요약은 방문자의 직접 입력이 아니라 사전 개념 키로 만들고(SummaryGenerator::Key),
  # 없으면 pending 행을 만들어 전용 큐에 한 번만 맡긴다(유일 인덱스가 동시 요청의 중복을 막는다).
  def summary
    response.headers["Cache-Control"] = "no-store"
    @summary_state, @summary = resolve_summary
  end

  # POST /self-care-form/result — [결과 보기]. 선택 동의한 사람의 선택을 구글 폼으로 보내고(켜진 배포에서만, 마지막으로
  # 보낸 값과 다를 때만) 결과 화면으로 간다. GET /result(새로고침·뒤로 가기)는 보내지 않는다. 구글 요청은 응답을 보낸
  # 뒤에 실행해 결과 화면이 구글 지연에 묶이지 않는다.
  def submit_result
    submit_stats if SelfCareForm.google_enabled? && session[:self_care_form_stats_consent]
    redirect_to self_care_form_result_path
  end

  # POST /self-care-form/reset — 답을 비우고 처음부터 다시 시작한다. 마지막으로 보낸 값의 해시
  # (:self_care_form_last_digest)는 일부러 지우지 않아, 같은 답으로 다시 해도 중복 전송하지 않는다.
  def reset
    session.delete(:self_care_form)
    session.delete(:self_care_summary)
    session.delete(:self_care_form_consent)
    session.delete(:self_care_form_stats_consent)
    redirect_to self_care_form_start_path
  end

  private

  # @return [Array(Symbol, SelfCareSummary|nil)] :off(동의 없음·기능 꺼짐), :none(결과 없음), :unavailable(이 조건은 요약 없음),
  #   :ready, :pending, :failed, :budget(오늘 EXAONE 요청 한도)
  def resolve_summary
    return [ :off, nil ] unless session[:self_care_form_consent] && SelfCareForm::SummaryGenerator.enabled?

    current = answers
    # 폴링 요청은 처음 요청이 세션에 남긴 행 id로 찾는다(CaseFinder·사실 쿼리를 다시 돌리지 않는다). 답이 바뀌면 지문이 달라 쓰지 않는다.
    cached = cached_summary(current)
    return [ :pending, cached ] if cached

    result = SelfCareForm::CaseFinder.new(current.search_conditions).call
    return [ :none, nil ] if result.records.empty?

    key = SelfCareForm::SummaryGenerator::Key.for(current, result)
    facts = key && SelfCareForm::SummaryGenerator.facts_for(key)
    return [ :unavailable, nil ] unless facts

    # 이미 만든 요약은 예산과 상관없이 보여 준다. 새로 만들려면 오늘 EXAONE 요청 예산이 남아 있어야 한다.
    return [ :budget, nil ] if SelfCareSummary.lookup(key, facts.digest).nil? && !SelfCareForm::ExaoneBudget.available?

    row, created = SelfCareSummary.claim(key, facts.digest)
    if row.budget_failure?
      return [ :budget, nil ] unless SelfCareForm::ExaoneBudget.available?

      row.update!(status: "pending", error_message: nil)
      created = true
    elsif row.stale? # 작업이 사라진 채 오래 pending이면 다시 맡긴다
      row.touch
      created = true
    end
    enqueue_summary(row) if created
    session[:self_care_summary] = { "id" => row.id, "digest" => answers_digest(current) }
    [ row.status.to_sym, row ]
  end

  # 세션에 남긴 행이 지금 답의 것이고 아직 만드는 중(오래되지 않음)일 때만 돌려준다. 그 밖에는 nil(전체 조회).
  def cached_summary(current)
    saved = session[:self_care_summary]
    return unless saved.is_a?(Hash) && saved["digest"] == answers_digest(current)

    row = SelfCareSummary.find_by(id: saved["id"])
    row if row&.pending? && !row.stale?
  end

  # 답(세션 값)의 SHA-256. 쿠키에는 행 id와 이 해시만 둔다.
  def answers_digest(current)
    Digest::SHA256.hexdigest(current.to_h.sort.to_json)
  end

  def enqueue_summary(row)
    SelfCareSummaryJob.perform_later(row.id)
  rescue StandardError => e
    Rails.logger.warn("[self_care_summary] 작업을 큐에 넣지 못했습니다 (#{e.class})")
    row.update!(status: "failed", error_message: "enqueue: #{e.class.name}")
  end

  def answers
    SelfCareForm::Answers.from_session(session[:self_care_form])
  end

  # 보낼 값(설정에 문항이 있는 키만)의 해시가 마지막으로 보낸 것과 다를 때만 보낸다. 쿠키에는 해시(hex)만 둔다.
  # 해시를 응답을 만들기 전에 같은 요청 안에서 먼저 켠다(중복 방지를 재시도보다 우선). 콜백은 응답을 보낸 뒤에
  # 돌기 때문에 거기서는 세션을 쓸 수 없다. 그래서 구글 요청이 실패해도 같은 답으로는 재시도하지 않는다.
  def submit_stats
    settings = SelfCareForm::Settings.current
    needs_result = (settings.entries.keys & %w[relaxed result_count]).any?
    result = needs_result ? SelfCareForm::CaseFinder.new(answers.search_conditions).call : nil
    values = SelfCareForm::GoogleFormSubmitter.values_for(answers, result: result)
    digest = stats_digest(values, settings)
    return if digest.nil? || digest == session[:self_care_form_last_digest]

    registered = after_response { SelfCareForm::GoogleFormSubmitter.new(settings: settings).submit(values) }
    return unless registered

    session[:self_care_form_last_digest] = digest
    flash[:stats_sent] = true
  end

  # 사용자 답에서 나온 보낼 값(키 정렬)의 SHA-256. 보낼 값이 없으면 nil.
  def stats_digest(values, settings)
    # relaxed·result_count는 데이터에 따라 바뀌므로 해시에서 뺀다(답이 같으면 다시 보내지 않는다).
    sendable = values.select do |key, value|
      settings.entries[key.to_s].present? && value.present? && !%w[relaxed result_count].include?(key.to_s)
    end
    return if sendable.empty?

    Digest::SHA256.hexdigest(sendable.sort.to_h.to_json)
  end

  # Rack 3 표준 rack.response_finished에 콜백을 단다. 달았으면 true, 배열이 없어 건너뛰었으면 false(이때는 제출 표시도
  # 켜지 않아 나중에 다시 시도할 수 있다). Puma는 응답을 보낸 뒤 같은 스레드에서 역순으로 실행하고
  # Rails 실행기도 같은 배열에 자기 완료 처리를 넣으므로, 콜백 안의 예외는 모두 삼킨다. 배열이 없으면 요청 처리 중에
  # 동기로 구글을 부르지 않고 건너뛴다.
  def after_response(&block)
    callbacks = request.env["rack.response_finished"]
    unless callbacks
      Rails.logger.warn("[self_care_form] rack.response_finished가 없어 구글 폼 전송을 건너뜁니다")
      return false
    end

    callbacks << lambda do |_env, _status, _headers, error|
      next if error

      begin
        block.call
      rescue StandardError => e
        Rails.logger.warn("[self_care_form] 구글 폼 전송 콜백 오류 (#{e.class})")
      end
    end
    true
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
