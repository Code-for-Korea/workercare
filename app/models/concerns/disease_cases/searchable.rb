module DiseaseCases
  module Searchable
    extend ActiveSupport::Concern

    KOREAN_PARTICLES = /(으로|에서|까지|부터|은|는|이|가|을|를|의|로|도|만|와|과)$/

    # FTS5 검색 가능한 컬럼 목록
    SEARCHABLE_COLUMNS = %w[
      application_content
      applicant_claim
      medical_records
      recognized_facts
      committee_decision
    ].freeze

    class_methods do
      def search(params = {})
        raw_query = params[:q].to_s.strip
        sort_param = params[:sort]
        search_columns = params[:search_in].presence || SEARCHABLE_COLUMNS

        fts_q = build_fts_query(raw_query, search_columns)
        tokens = normalize_query(raw_query).split(" ").first(5)

        if fts_q.present?
          scope = fulltext(fts_q)
          if scope.empty?
            scope = substring_fallback(tokens)
            fallback = true
          else
            fallback = false
          end
        else
          scope = all
          fallback = false
        end

        scope = apply_filters(scope, params)
        scope = apply_sort(scope, fts_q, fallback, sort_param)
        [ scope, fallback ]
      end

      private

      def apply_filters(scope, params)
        scope = scope.where(result: params[:result]) if params[:result].present?
        scope = scope.where(year: params[:year]) if params[:year].present?
        scope = apply_array_filter(scope, :disease_category, params[:disease_category])
        scope = apply_array_filter(scope, :body_part, params[:body_part])
        scope.by_date_range(params[:decided_on_from].presence, params[:decided_on_to].presence)
      end

      def apply_array_filter(scope, column, values)
        return scope if values.blank?

        values = Array(values).reject(&:blank?)
        return scope if values.empty?

        scope.where(column => values)
      end

      def apply_sort(scope, fts_q, fallback, sort_param)
        if fts_q.present? && !fallback && sort_param != "recent"
          scope.order(Arel.sql("bm25(disease_cases_fts, 1.0, 0.5, 2.0, 1.5, 1.5)"))
        else
          scope.order(year: :desc)
        end
      end

      def normalize_query(raw)
        raw.to_s.unicode_normalize(:nfkc).gsub(/\s+/, " ").strip
      end

      def build_fts_query(raw, columns = SEARCHABLE_COLUMNS)
        query = normalize_query(raw)
        return nil if query.blank?

        tokens = query.split(" ").first(5).map { |token| token.gsub(KOREAN_PARTICLES, "") }.reject(&:blank?)
        return nil if tokens.empty?

        # 컬럼 지정 검색: 각 토큰을 선택된 컬럼들에서 OR 검색
        token_queries = tokens.map { |token|
          escaped = token.gsub('"', '""')
          quoted_token = "\"#{escaped}\""

          if columns.size == SEARCHABLE_COLUMNS.size
            # 모든 컬럼 검색 시 컬럼 지정 없이 검색 (기존 동작)
            quoted_token
          else
            # 특정 컬럼만 검색: 각 컬럼에서 OR 검색
            columns.map { |col| "#{col}:#{quoted_token}" }.join(" OR ")
          end
        }

        token_queries.join(" AND ")
      end

      def substring_fallback(tokens)
        safe_tokens = tokens.first(2).map { |token| sanitize_sql_like(token) }
        conditions = safe_tokens.map { "disease_name LIKE ?" }.join(" AND ")
        binds = safe_tokens.map { |token| "%#{token}%" }
        where(conditions, *binds)
      end
    end
  end
end
