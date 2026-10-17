module DiseaseCases
  module MainSearchable
    extend ActiveSupport::Concern

    MAIN_SEARCHABLE_COLUMNS = %w[
      job_name
      job_description
      main_reasoning
      other_harmful_factors
      aggravating_factors
    ].freeze

    class_methods do
      def main_search(params = {})
        raw_query = params[:q].to_s.strip
        fts_q = build_main_fts_query(raw_query)
        tokens = normalize_query(raw_query).split(" ").first(5)

        # 1. Full-text scope (새 FTS5 가상 테이블 사용)
        if fts_q.present?
          scope = main_fulltext(fts_q)
          if scope.empty?
            scope = substring_job_fallback(tokens)
            fallback = true
          else
            # 챗봇(5초 응답 제한)은 FTS를 필터로만 쓰고 최신순으로 정렬한다. JOIN + bm25 정렬은
            # 매칭 행 전체에 점수를 매겨, 구조 필터가 넓으면(예: 작업 요인 + 판정) 수 초가 걸린다.
            scope = main_fulltext_filter(fts_q) if params[:fts_as_filter]
            fallback = false
          end
        else
          scope = all
          fallback = false
        end

        # 2. Structured filters
        scope = apply_main_filters(scope, params)

        # 3. Sort
        sort = params[:fts_as_filter] ? "recent" : params[:sort]
        scope = apply_main_sort(scope, fts_q, fallback, sort)

        [ scope, fallback ]
      end

      # MCP search_disease_cases_tool처럼 legacy DiseaseCase.search 결과에 새 구조화 필터를
      # 추가로 적용하고 싶은 호출부를 위해 public으로 유지한다 (main_search 내부에서도 재사용).
      def apply_main_filters(scope, params)
        # FTS 가상 테이블(disease_cases_extracted_fts)과 JOIN되는 경우 job_name 등이 모호해지므로
        # 컬럼은 항상 disease_cases.로 한정한다.
        # 직업/하는일: 부분 일치 (LIKE) — exact match는 표현 통일성이 없는 추출 데이터에서 0건 위험
        if params[:job_name].present?
          safe = sanitize_sql_like(params[:job_name])
          scope = scope.where("disease_cases.job_name LIKE ?", "%#{safe}%")
        end

        if params[:job_description].present?
          safe = sanitize_sql_like(params[:job_description])
          scope = scope.where("disease_cases.job_description LIKE ?", "%#{safe}%")
        end

        # 직종 이름 여러 개(챗봇의 직종 검색 스킬에서 고른 값). DB에 있는 이름 그대로 띄어쓰기를 무시하고
        # 일치시킨다(OR). 웹 검색 화면은 이 값을 받지 않는다(main_search_params에 없음).
        if params[:job_names].present?
          names = Array(params[:job_names]).map { |name| name.to_s.gsub(/\s+/, "") }.reject(&:empty?)
          scope = scope.where("REPLACE(disease_cases.job_name, ' ', '') IN (?)", names) if names.any?
        end

        # 질병명은 main_search의 FTS 대상 컬럼에 없으므로(MAIN_SEARCHABLE_COLUMNS) q로는 찾을 수 없다.
        # job_name과 같은 LIKE 부분 일치로 처리한다. 챗봇 어댑터가 사용한다(웹 UI에는 입력 없음).
        if params[:disease_name].present?
          safe = sanitize_sql_like(params[:disease_name])
          scope = scope.where("disease_cases.disease_name LIKE ?", "%#{safe}%")
        end

        # 판정 결과(enum 값 일치). 알 수 없는 값은 0건이 되므로 호출부에서 변환·검증한다.
        scope = scope.where(result: params[:result]) if params[:result].present?

        # 부담_신체_부위는 파이프(|)로 구분된 다중값 텍스트다(예: "목|상체|하체").
        # exact match나 단순 LIKE '%값%'은 "목"이 "손목"/"발목"/"뒷목"까지 잘못 매칭하므로,
        # 파이프 경계를 인식하는 매칭으로 처리한다. 컬럼 양끝에 파이프를 붙여('|목|상체|하체|')
        # '%|값|%' 하나로 정확히 일치/맨앞/맨뒤/중간을 모두 잡는다. 값마다 LIKE를 4번 쓰던 방식과
        # 결과가 같고, 챗봇이 한 개념을 토큰 수십 개로 확장해 찾을 때 4배 빠르다(5초 응답 제한).
        if params[:burden_body_part].present? || params[:burden_body_part_text].present?
          values = Array(params[:burden_body_part]).reject(&:blank?)
          values << params[:burden_body_part_text].to_s.strip if params[:burden_body_part_text].present?
          if values.any?
            conditions = Array.new(values.size, "('|' || disease_cases.burden_body_part || '|') LIKE ?").join(" OR ")
            binds = values.map { |v| "%|#{sanitize_sql_like(v)}|%" }
            scope = scope.where(conditions, *binds)
          end
        end

        scope = scope.where(death_status: params[:death_status]) if params[:death_status].present?
        scope = scope.where(application_type: params[:application_type]) if params[:application_type].present?
        # employment_type은 distinct 값이 1,583개로 잘게 쪼개져 있어(예: "1년 계약직"/
        # "1년 계약직(비정규직)") 웹 UI에는 입력을 두지 않는다(사용자가 직접 골라 검색할 이유가
        # 없음). MCP 클라이언트가 구조화 필터로 넘길 때만 exact match로 쓰인다.
        scope = scope.where(employment_type: params[:employment_type]) if params[:employment_type].present?

        # work_type은 distinct 값이 14,582개로(예: "02:30~11:30 (평일 및 토요일)") 사실상 자유 텍스트라
        # <datalist>로 목록화할 수 없다(3.2절). exact match를 쓰면 사용자가 직접 입력한 값이 저장된
        # 문자열과 한 글자라도 다르면 0건이 되므로, job_name/job_description과 같은 LIKE 부분 일치로 처리한다.
        if params[:work_type].present?
          safe = sanitize_sql_like(params[:work_type])
          scope = scope.where("work_type LIKE ?", "%#{safe}%")
        end

        scope = scope.where(work_relevance_eval: params[:work_relevance_eval]) if params[:work_relevance_eval].present?

        # KSCO 코드 필터 (JOIN) — `.distinct` 필수: 하나의 판정서가 여러 KSCO 코드와 매핑될 수 있으므로
        # 멀티 선택 시 동일 판정서가 중복 행으로 노출되고 pagy 카운트가 부풀려지는 것을 방지
        if params[:ksco_code].present?
          codes = Array(params[:ksco_code]).reject(&:blank?)
          scope = scope.joins(:ksco_codes).where(ksco_codes: { code: codes }).distinct if codes.any?
        end

        scope
      end

      private

      def apply_main_sort(scope, fts_q, fallback, sort_param)
        if fts_q.present? && !fallback && sort_param != "recent"
          scope.order(Arel.sql("bm25(disease_cases_extracted_fts, 1.0, 1.0, 2.0, 0.5, 0.5)"))
        else
          scope.order(year: :desc)
        end
      end

      def main_fulltext(query)
        joins("JOIN disease_cases_extracted_fts ON disease_cases_extracted_fts.rowid = disease_cases.id")
          .where("disease_cases_extracted_fts MATCH ?", query)
      end

      def main_fulltext_filter(query)
        where("disease_cases.id IN (SELECT rowid FROM disease_cases_extracted_fts WHERE disease_cases_extracted_fts MATCH ?)", query)
      end

      def build_main_fts_query(raw)
        query = normalize_query(raw)
        return nil if query.blank?

        tokens = query.split(" ").first(5)
          .map { |token| token.gsub(DiseaseCases::Searchable::KOREAN_PARTICLES, "") }
          .reject(&:blank?)
        return nil if tokens.empty?

        tokens.map { |token| "\"#{token.gsub('"', '""')}\"" }.join(" AND ")
      end

      def substring_job_fallback(tokens)
        safe_tokens = tokens.first(2).map { |token| sanitize_sql_like(token) }
        conditions = safe_tokens.map { "job_name LIKE ? OR job_description LIKE ?" }.join(" AND ")
        binds = safe_tokens.flat_map { |token| [ "%#{token}%", "%#{token}%" ] }
        where(conditions, *binds)
      end
    end
  end
end
