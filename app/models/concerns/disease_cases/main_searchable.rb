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
            fallback = false
          end
        else
          scope = all
          fallback = false
        end

        # 2. Structured filters
        scope = apply_main_filters(scope, params)

        # 3. Sort
        scope = apply_main_sort(scope, fts_q, fallback, params[:sort])

        [ scope, fallback ]
      end

      # MCP search_disease_cases_tool처럼 legacy DiseaseCase.search 결과에 새 구조화 필터를
      # 추가로 적용하고 싶은 호출부를 위해 public으로 유지한다 (main_search 내부에서도 재사용).
      def apply_main_filters(scope, params)
        # 직업/하는일: 부분 일치 (LIKE) — exact match는 표현 통일성이 없는 추출 데이터에서 0건 위험
        if params[:job_name].present?
          safe = sanitize_sql_like(params[:job_name])
          scope = scope.where("job_name LIKE ?", "%#{safe}%")
        end

        if params[:job_description].present?
          safe = sanitize_sql_like(params[:job_description])
          scope = scope.where("job_description LIKE ?", "%#{safe}%")
        end

        # 부담_신체_부위는 파이프(|)로 구분된 다중값 텍스트다(예: "목|상체|하체").
        # exact match나 단순 LIKE '%값%'은 "목"이 "손목"/"발목"/"뒷목"까지 잘못 매칭하므로,
        # 파이프 경계를 인식하는 매칭(정확히 일치/맨앞/맨뒤/중간)으로 처리한다.
        if params[:burden_body_part].present? || params[:burden_body_part_text].present?
          values = Array(params[:burden_body_part]).reject(&:blank?)
          values << params[:burden_body_part_text].to_s.strip if params[:burden_body_part_text].present?
          if values.any?
            conditions = values.map {
              "(burden_body_part = ? OR burden_body_part LIKE ? OR burden_body_part LIKE ? OR burden_body_part LIKE ?)"
            }.join(" OR ")
            binds = values.flat_map { |v|
              safe = sanitize_sql_like(v)
              [ v, "#{safe}|%", "%|#{safe}", "%|#{safe}|%" ]
            }
            scope = scope.where(conditions, *binds)
          end
        end

        scope = scope.where(death_status: params[:death_status]) if params[:death_status].present?
        scope = scope.where(application_type: params[:application_type]) if params[:application_type].present?
        scope = scope.where(employment_type: params[:employment_type]) if params[:employment_type].present?
        scope = scope.where(work_type: params[:work_type]) if params[:work_type].present?
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
