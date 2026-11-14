# frozen_string_literal: true

require "csv"
require "json"

module DiseaseCases
  # 추출 CSV의 ksco_codes_json을 disease_case_ksco_codes에 반영한다(rake import:ksco_mappings).
  # import:extracted_disease_cases와 달리 추출 컬럼·FTS는 건드리지 않고 매핑 테이블만 바꾼다.
  #
  # 규칙
  # - 기본은 dry-run(아무것도 쓰지 않고 건수만 센다). apply: true일 때만 쓴다.
  # - 같은 case_no가 여러 행이면 마지막 행이 이긴다.
  # - ksco_codes_json이 비었거나 깨진 행은 기존 매핑을 그대로 둔다(빈 값과 누락을 구분할 수 없으므로 보존).
  # - 파싱된 목록이 "전체 목표"다. 목록에 없는 기존 매핑은 지운다.
  #   단 ksco_codes 테이블에 없는 코드도 "목록에 있는 코드"로 센다(참조 데이터 누락이 삭제로 번지지 않게).
  # - 한 행 안에서 같은 코드가 둘이면 유사도가 큰 쪽을 쓴다.
  class KscoMappingImporter
    BATCH = 500
    EPSILON = 1e-9

    Result = Struct.new(:rows, :cases, :inserted, :updated, :deleted, :unchanged, :preserved_blank, :preserved_broken,
      :unknown_cases, :unknown_codes, :duplicate_case_rows, keyword_init: true)

    def initialize(path, apply: false, logger: nil)
      @path = path
      @apply = apply
      @logger = logger
      @result = Result.new(rows: 0, cases: 0, inserted: 0, updated: 0, deleted: 0, unchanged: 0, preserved_blank: 0,
        preserved_broken: 0, unknown_cases: 0, unknown_codes: Hash.new(0), duplicate_case_rows: 0)
    end

    attr_reader :result

    def apply? = @apply

    def call
      targets = read_targets
      case_ids = DiseaseCase.where(case_no: targets.keys).pluck(:case_no, :id).to_h
      known_codes = KscoCode.pluck(:code).to_set

      targets.each_slice(BATCH) do |slice|
        process_batch(slice, case_ids, known_codes)
      end
      result
    end

    private

    # { case_no => { code => similarity } } — 파싱에 성공한 행만. 깨진·빈 행은 건수만 센다.
    def read_targets
      targets = {}
      CSV.foreach(@path, headers: true, encoding: "UTF-8") do |row|
        result.rows += 1
        case_no = row["case_no"].to_s.strip
        raw = row["ksco_codes_json"].to_s.strip

        parsed = nil
        if raw.empty?
          result.preserved_blank += 1
        else
          begin
            parsed = JSON.parse(raw)
            raise JSON::ParserError, "배열이 아님" unless parsed.is_a?(Array)
          rescue JSON::ParserError
            result.preserved_broken += 1
            warn_log("ksco_codes_json 파싱 실패, 기존 매핑 유지 (case_no=#{case_no})")
            parsed = nil
          end
        end

        result.duplicate_case_rows += 1 if targets.key?(case_no)
        if parsed
          targets[case_no] = codes_from(parsed)
        else
          # 뒤 행이 빈 값이라 앞 행의 목표를 지우면 안 되므로, 마지막 행이 이긴다는 규칙을 그대로 적용한다.
          targets.delete(case_no)
        end
      end
      targets
    end

    def codes_from(items)
      items.each_with_object({}) do |item, codes|
        next unless item.is_a?(Hash)

        code = item["ksco_code"].to_s.strip
        next if code.empty?

        similarity = item["similarity"].to_f
        codes[code] = [ codes[code], similarity ].compact.max
      end
    end

    def process_batch(slice, case_ids, known_codes)
      ids = slice.filter_map { |case_no, _| case_ids[case_no] }
      existing = DiseaseCaseKscoCode.where(disease_case_id: ids).pluck(:disease_case_id, :ksco_code_id, :similarity, :id)
        .group_by(&:first)

      inserts = []
      updates = [] # [id, similarity]
      deletes = []

      slice.each do |case_no, codes|
        case_id = case_ids[case_no]
        unless case_id
          result.unknown_cases += 1
          warn_log("판정서 없음: #{case_no}")
          next
        end
        result.cases += 1

        current = (existing[case_id] || []).to_h { |_, code, sim, id| [ code, [ sim, id ] ] }
        codes.each do |code, similarity|
          unless known_codes.include?(code)
            result.unknown_codes[code] += 1
            next
          end

          if (stored = current[code])
            if stored[0].nil? || (stored[0] - similarity).abs > EPSILON
              updates << [ stored[1], similarity ]
            else
              result.unchanged += 1
            end
          else
            inserts << { disease_case_id: case_id, ksco_code_id: code, similarity: similarity }
          end
        end
        deletes.concat(current.reject { |code, _| codes.key?(code) }.values.map(&:last))
      end

      result.inserted += inserts.size
      result.updated += updates.size
      result.deleted += deletes.size
      write(inserts, updates, deletes) if apply?
    end

    def write(inserts, updates, deletes)
      ActiveRecord::Base.transaction do
        DiseaseCaseKscoCode.where(id: deletes).delete_all if deletes.any?
        updates.each { |id, similarity| DiseaseCaseKscoCode.where(id: id).update_all(similarity: similarity) }
        DiseaseCaseKscoCode.insert_all(inserts) if inserts.any?
      end
    end

    def warn_log(message)
      @logger&.warn(message)
    end
  end
end
