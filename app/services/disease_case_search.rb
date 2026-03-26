class DiseaseCaseSearch
  RESULT_CAP = 500

  # 복합 조사를 먼저 — 순서 중요 ("으로"가 "로"보다 앞에 와야 함)
  KOREAN_PARTICLES = /(으로|에서|까지|부터|은|는|이|가|을|를|의|로|도|만|와|과)$/

  attr_reader :raw_query, :fallback
  alias fallback? fallback

  def initialize(params = {})
    @raw_query      = params[:q].to_s.strip
    @result_param   = params[:result]
    @year_param     = params[:year]
    @category_param = params[:disease_category]
    @body_param     = params[:body_part]
    @date_from      = params[:decided_on_from]
    @date_to        = params[:decided_on_to]
    @sort_param     = params[:sort]
    @fallback       = false
  end

  # 캡 처리된 배열 + 메타데이터 반환. 페이지네이션은 컨트롤러에서 pagy_array로.
  def capped_results
    raw       = build_scope.capped(RESULT_CAP).to_a
    over_cap  = raw.size > RESULT_CAP
    count     = over_cap ? nil : raw.size
    results   = raw.first(RESULT_CAP)
    [ over_cap, count, results ]
  end

  private

  def build_scope
    fts_q  = build_fts_query(@raw_query)
    tokens = normalize_query(@raw_query).split(" ").first(5)

    if fts_q.present?
      scope = DiseaseCase.fulltext(fts_q)
      if scope.empty?
        @fallback = true
        scope = substring_fallback(tokens)
      end
    else
      scope = DiseaseCase.all
    end

    scope = scope
      .by_result(@result_param)
      .by_year(@year_param)
      .by_category(@category_param)
      .by_body(@body_param)
      .by_date_range(@date_from, @date_to)

    apply_sort(scope, fts_q)
  end

  def apply_sort(scope, fts_q)
    if fts_q.present? && !@fallback && @sort_param != "recent"
      scope.order(Arel.sql("bm25(disease_cases_fts, 1.0, 0.5, 2.0, 1.5, 1.5)"))
    else
      scope.order(year: :desc)
    end
  end

  def normalize_query(raw)
    raw.to_s.unicode_normalize(:nfkc).gsub(/\s+/, " ").strip
  end

  def build_fts_query(raw)
    q = normalize_query(raw)
    return nil if q.blank?

    tokens = q.split(" ")
               .first(5)
               .map { |token| token.gsub(KOREAN_PARTICLES, "") }
               .reject(&:blank?)

    return nil if tokens.empty?

    tokens.map { |token|
      escaped = token.gsub('"', '""')
      "\"#{escaped}\""
    }.join(" AND ")
  end

  def substring_fallback(tokens)
    safe_tokens = tokens.first(2).map { |t| ActiveRecord::Base.sanitize_sql_like(t) }
    conditions  = safe_tokens.map { "disease_name LIKE ?" }.join(" AND ")
    binds       = safe_tokens.map { |t| "%#{t}%" }
    DiseaseCase.where(conditions, *binds)
  end
end
