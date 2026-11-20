# frozen_string_literal: true

require "csv"

module SolarExtraction
  # 정답(gold) 표본 선정: disease_category(NULL 포함) × result로 층화하고 비례 배분한다(층마다 최소 min_per건).
  # 같은 seed·같은 데이터면 같은 표본이 나온다. 본문은 읽지 않고 LLM도 쓰지 않는다. 사람이 라벨을 다는 CSV만 만든다.
  class GoldSample
    DEFAULT_SEED = 20_261_118
    DEFAULT_MIN_PER_STRATUM = 3
    LABEL_COLUMNS = %w[
      comorbidity_comorbidities comorbidity_smoking comorbidity_alcohol comorbidity_preexisting_source
      prior_career_mention prior_career_months prior_career_list
      labeler notes
    ].freeze
    HEADERS = (%w[case_no disease_category result year link] + LABEL_COLUMNS).freeze
    BLANK = "(NULL)"

    Row = Struct.new(:case_no, :disease_category, :result, :year, :link)

    def initialize(size:, seed: DEFAULT_SEED, min_per_stratum: DEFAULT_MIN_PER_STRATUM)
      @size = Integer(size)
      @seed = Integer(seed)
      @min = min_per_stratum
      raise ArgumentError, "표본 크기는 1 이상이어야 합니다" if @size < 1
    end

    attr_reader :size, :seed

    def self.default_path(size, seed)
      Rails.root.join("storage/exports/solar/gold/gold_sample_#{size}_#{seed}.csv")
    end

    # @return [Array<Row>] 선정된 행(층 순서, case_no 순)
    def select_rows(rows = DiseaseCase.order(:case_no).pluck(:case_no, :disease_category, :result, :year, :link).map { |r| Row.new(*r) })
      strata = rows.group_by { |row| stratum_key(row) }
      keys = strata.keys.sort
      allocation = allocate(keys.to_h { |key| [ key, strata[key].size ] })
      rng = Random.new(@seed)
      keys.flat_map do |key|
        members = strata[key].sort_by(&:case_no)
        members.shuffle(random: rng).first(allocation[key]).sort_by(&:case_no)
      end
    end

    # 층별 건수 요약: { [category, result] => [모집단, 표본] }
    def summary(rows, selected)
      population = rows.group_by { |row| stratum_key(row) }.transform_values(&:size)
      picked = selected.group_by { |row| stratum_key(row) }.transform_values(&:size)
      population.keys.sort.to_h { |key| [ key, [ population[key], picked.fetch(key, 0) ] ] }
    end

    def csv(selected)
      "﻿" + CSV.generate do |out|
        out << HEADERS
        selected.each do |row|
          out << [ row.case_no, row.disease_category, row.result, row.year, row.link ] + Array.new(LABEL_COLUMNS.size)
        end
      end
    end

    private

    def stratum_key(row)
      [ row.disease_category.presence || BLANK, row.result.presence || BLANK ]
    end

    # 비례 배분 + 층마다 최소 min건(층 크기 이내). 합이 size가 되도록 가장 큰 층부터 조정한다. 모집단보다 크면 전부.
    def allocate(counts)
      total = counts.values.sum
      return counts.dup if @size >= total

      alloc = counts.to_h { |key, count| [ key, [ [ (@size * count.to_f / total).floor, @min ].max, count ].min ] }
      # 넘치면 최소치 위에서 큰 층부터 줄이고(최소치만 남았으면 가장 큰 층부터), 모자라면 여유가 큰 층부터 늘린다(동률은 키 순).
      while alloc.values.sum > @size
        floor = ->(key) { [ @min, counts[key] ].min }
        candidates = alloc.select { |key, value| value > floor.call(key) }
        candidates = alloc.select { |_, value| value > 0 } if candidates.empty?
        alloc[candidates.max_by { |key, value| [ value, key ] }.first] -= 1
      end
      while alloc.values.sum < @size
        key = counts.keys.select { |k| alloc[k] < counts[k] }.max_by { |k| [ counts[k] * 1.0 / [ alloc[k], 1 ].max, counts[k] - alloc[k], k ] }
        break unless key

        alloc[key] += 1
      end
      alloc
    end
  end
end
