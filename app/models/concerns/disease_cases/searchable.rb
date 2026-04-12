module DiseaseCases
  module Searchable
    extend ActiveSupport::Concern

    KOREAN_PARTICLES = /(으로|에서|까지|부터|은|는|이|가|을|를|의|로|도|만|와|과)$/

    class_methods do
      def search(params = {})
        raw_query = params[:q].to_s.strip
        sort_param = params[:sort]

        fts_q = build_fts_query(raw_query)
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
        scope = scope.where(disease_category: params[:disease_category]) if params[:disease_category].present?
        scope = scope.where(body_part: params[:body_part]) if params[:body_part].present?
        scope.by_date_range(params[:decided_on_from], params[:decided_on_to])
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

      def build_fts_query(raw)
        query = normalize_query(raw)
        return nil if query.blank?

        tokens = query.split(" ").first(5).map { |token| token.gsub(KOREAN_PARTICLES, "") }.reject(&:blank?)
        return nil if tokens.empty?

        tokens.map { |token|
          escaped = token.gsub('"', '""')
          "\"#{escaped}\""
        }.join(" AND ")
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
