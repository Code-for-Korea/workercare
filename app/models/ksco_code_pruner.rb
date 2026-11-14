# frozen_string_literal: true

require "csv"

# CSV(세분류 목록)에 없는 ksco_codes 행과 그 매핑(disease_case_ksco_codes)을 찾아 지운다.
# 기본은 dry-run이고 apply: true일 때만 한 트랜잭션으로 지운다. 판정서·유사도·다른 코드의 매핑은 건드리지 않는다.
class KscoCodePruner
  Extra = Struct.new(:code, :name, :mappings, :cases, keyword_init: true)
  Result = Struct.new(:csv_codes, :db_codes, :extras, :missing_in_db, :deleted_mappings, :deleted_codes, :applied, keyword_init: true)

  class Refused < StandardError; end

  MAX_DELETE_RATIO = 0.5

  def initialize(path, apply: false)
    @path = path
    @apply = apply
  end

  def call
    csv_codes = read_codes
    raise Refused, "CSV에서 코드를 하나도 읽지 못했습니다(헤더 '코드'를 확인하세요): #{@path}" if csv_codes.empty?

    db_codes = KscoCode.pluck(:code)
    extra_codes = (db_codes - csv_codes.to_a).sort
    if db_codes.any? && extra_codes.size > db_codes.size * MAX_DELETE_RATIO
      raise Refused, "지울 코드가 #{extra_codes.size}개로 전체 #{db_codes.size}개의 절반을 넘습니다. 다른 CSV를 가리킨 것은 아닌지 확인하세요."
    end

    extras = extra_codes.map { |code| describe(code) }
    result = Result.new(csv_codes: csv_codes.size, db_codes: db_codes.size, extras: extras,
                        missing_in_db: (csv_codes.to_a - db_codes).sort, deleted_mappings: 0, deleted_codes: 0, applied: @apply)
    delete(extra_codes, result) if @apply && extra_codes.any?
    result
  end

  private

  def read_codes
    CSV.foreach(@path, headers: true, encoding: "UTF-8").filter_map { |row| row["코드"].to_s.strip.presence }.to_set
  end

  def describe(code)
    mappings = DiseaseCaseKscoCode.where(ksco_code_id: code)
    Extra.new(code: code, name: KscoCode.where(code: code).pick(:name), mappings: mappings.count, cases: mappings.distinct.count(:disease_case_id))
  end

  def delete(codes, result)
    KscoCode.transaction do
      result.deleted_mappings = DiseaseCaseKscoCode.where(ksco_code_id: codes).delete_all
      result.deleted_codes = KscoCode.where(code: codes).delete_all
    end
  end
end
