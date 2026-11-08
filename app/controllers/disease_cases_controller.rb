class DiseaseCasesController < ApplicationController
  MAX_SEARCH_RESULTS = 500
  BURDEN_BODY_PART_CHECKBOX_LIMIT = 12
  # wip/cerebras_prompts.rb 추출 스키마상 허용값 6개 전부 (docs/workercare-search.plan.md 3.2절) —
  # DB에도 이 6개만 존재하는 진짜 enum이라 distinct pluck 대신 고정 목록을 순서대로 노출한다.
  WORK_RELEVANCE_EVAL_OPTIONS = %w[매우_높음 높음 보통 낮음 매우_낮음 미흡].freeze

  # 같은 주소를 .md 확장자나 `Accept: text/markdown`으로 부르면 마크다운으로 응답한다(LLM·스크립트용,
  # docs/markdown-responses.md). 두 표현 모두 `Vary: Accept`와 서로를 가리키는 `Link` 헤더를 단다.
  include RepresentationHeaders
  advertise_markdown

  # / (메인 화면). 간단한 검색을 위해 직업·부담 신체 부위·사망 여부·신청서 유형만 노출한다 —
  # 근무형태/업무관련성은 /search(상세 검색)에서만 노출한다. KSCO 코드는 숫자라 사용자가 직접 골라
  # 검색할 이유가 없어 웹 UI에는 없다. apply_main_filters/main_search_params는 ksco_code도 그대로 받아
  # URL로 직접 호출하는 클라이언트(직업 설명 → KSCO 코드 매핑)는 계속 쓸 수 있다.
  def index
    perform_search(legacy: false)
    set_common_filter_options
    respond_to do |format|
      format.html
      format.md { render_markdown_search("/index") }
    end
  end

  # /search (상세 검색, 이전에는 root였다). 메인 화면 필터도 함께 쓸 수 있도록
  # apply_main_filters를 추가로 적용한다.
  def search
    perform_search(legacy: true)
    set_common_filter_options
    respond_to do |format|
      format.html
      format.md { render_markdown_search("/search") }
    end
  end

  def show
    @disease_case = DiseaseCase.find_by!(case_no: params[:case_no])
    respond_to do |format|
      format.html
      format.md { render_markdown(markdown_renderer.show(@disease_case)) }
    end
  end

  private

  def markdown_renderer
    DiseaseCases::MarkdownRenderer.new(base_url: request.base_url)
  end

  def render_markdown_search(path)
    options = {
      application_type: @application_type_options, employment_type: @employment_type_options,
      work_type: @work_type_options, work_relevance_eval: @work_relevance_eval_options,
      burden_body_part: @burden_body_part_options
    }
    body = markdown_renderer.search(cases: @cases, pagy: @pagy, metadata: @metadata, path: path,
      query: request.query_parameters.except("page", "format"), options: options)
    render_markdown(body)
  end

  def render_markdown(body)
    render plain: body, content_type: "text/markdown; charset=utf-8"
  end

  def perform_search(legacy:)
    if legacy
      @scope, @fallback = DiseaseCase.search(search_params)
      @scope = DiseaseCase.apply_main_filters(@scope, main_search_params)
    else
      @scope, @fallback = DiseaseCase.main_search(main_search_params)
    end
    @pagy, @cases = paginate(@scope)
    @metadata = build_metadata

    log_search_event
  end

  def set_common_filter_options
    counts = burden_body_part_token_counts
    @burden_body_part_options = burden_body_part_options(counts)
    @burden_body_part_datalist_options = burden_body_part_datalist_options(counts)
    @application_type_options = application_type_options
    @employment_type_options = employment_type_options
    @work_type_options = work_type_options
    @work_relevance_eval_options = WORK_RELEVANCE_EVAL_OPTIONS
  end

  # burden_body_part는 파이프(|) 구분 다중값 텍스트이며 실 데이터 기준 distinct 토큰이
  # 1,000개를 넘는 자유 텍스트라(사전 정의된 enum이 아님 — 3.2절 참고), 체크박스로는
  # 자주 쓰는 상위 N개만 노출하고 나머지는 <datalist> 자동완성 텍스트 입력으로 찾는다.
  # 요청마다 4만 건을 읽어 집계하면 메모리가 작은 서버에서 디스크 I/O 때문에 수 초가 걸려,
  # 필터 옵션은 하루 동안 캐시한다. 데이터를 다시 임포트하면 최대 하루 뒤에 반영된다
  # (바로 반영하려면 Rails.cache.delete("disease_cases/burden_body_part_token_counts")).
  def burden_body_part_token_counts
    Rails.cache.fetch("disease_cases/burden_body_part_token_counts", expires_in: 1.day) do
      counts = Hash.new(0)
      DiseaseCase.where.not(burden_body_part: [ nil, "" ]).pluck(:burden_body_part).each do |raw|
        raw.split("|").each { |token| counts[token.strip] += 1 unless token.strip.blank? }
      end
      counts.to_h
    end
  end

  def burden_body_part_options(counts)
    counts.sort_by { |_, count| -count }
      .first(BURDEN_BODY_PART_CHECKBOX_LIMIT).map(&:first).sort
  end

  def burden_body_part_datalist_options(counts)
    counts.keys.sort
  end

  # 정규화된 토큰 8개 + 기타(config/normalization/rules.yml). 값 목록이 고정이라 distinct 조회가 필요 없다.
  def application_type_options
    rules = DiseaseCases::Normalizer::RULES.fetch("application_type")
    rules.fetch("tokens").map { |t| t["name"] } << rules.fetch("other")
  end

  def employment_type_options
    rules = DiseaseCases::Normalizer::RULES.fetch("employment_type")
    rules.fetch("categories").map { |c| c["name"] }.uniq.reject { |n| n == rules.fetch("other") } << rules.fetch("other")
  end

  def work_type_options
    rules = DiseaseCases::Normalizer::RULES.fetch("work_type")
    rules.fetch("categories").map { |c| c["name"] } << rules.fetch("other")
  end

  def paginate(scope)
    pagy(scope, items: 12, max_items: MAX_SEARCH_RESULTS)
  end

  def build_metadata
    over_cap = @pagy.count >= MAX_SEARCH_RESULTS

    {
      total_count: over_cap ? nil : @pagy.count,
      over_cap: over_cap,
      used_fallback: @fallback
    }
  end

  def search_params
    params.permit(:q, :result, :year, :decided_on_from, :decided_on_to, :sort, :commit, :search, search_in: [], disease_category: [], body_part: [])
  end

  def main_search_params
    params.permit(
      :q, :job_name, :job_description, :disease_name, :result,
      :death_status, :application_type, :employment_type, :work_type,
      :work_relevance_eval, :sort, :commit, :search,
      :burden_body_part_text,
      application_type: [], burden_body_part: [], job_name_any: [], ksco_code: []
    )
  end

  def log_search_event
    Rails.logger.info({
      event: "search",
      query: params[:q],
      result_count: @metadata[:total_count],
      over_cap: @metadata[:over_cap],
      used_fallback: @fallback,
      format: request.format.symbol,
      user_agent: request.user_agent.to_s[0, 60]
    }.to_json)
  end
end
