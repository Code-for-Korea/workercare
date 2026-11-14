# frozen_string_literal: true

# 판정서 분석 통계표를 DB 질의만으로 다시 만든다(마크다운). 읽기 전용이고 LLM·외부 API를 쓰지 않는다.
# 대상은 wip/workercare-hermes.md [A]의 2~7장이고, 규칙이 문서에 없는 전문 텍스트 마이닝(6.1·6.2·6.4·6.5)과
# 상병군 정규화(5.3)는 만들지 않고 "재현 불가"로 표시한다. 사용법·재현성 표는 docs/analysis-report.md.
class AnalysisReport
  RESULT_KO = {
    "approved" => "인정", "partially_approved" => "일부인정",
    "revised_approved" => "변경인정", "rejected" => "불인정"
  }.freeze
  CATEGORY_KO = {
    "musculoskeletal" => "근골격계질병", "cardiovascular" => "뇌심혈관계질병",
    "other_disease" => "기타질병", "pneumoconiosis" => "진폐"
  }.freeze
  BODY_PART_KO = {
    "arm" => "팔", "lower_back" => "허리", "leg" => "다리", "other" => "기타", "neck" => "목",
    "whole_body" => "전신", "multiple" => "복합부위", "eye" => "눈", "hip" => "엉덩이", "abdomen" => "복부"
  }.freeze
  RELEVANCE_ORDER = %w[매우_높음 높음 보통 낮음 매우_낮음 미흡].freeze
  BLANK = "-"
  NO_BODY_PART = "신체부위 미기록"
  DECOMPOSED_TOKENS = %w[어깨 허리 목 손목 팔꿈치].freeze
  TOP_TOKENS = 15

  REPRODUCIBILITY = [
    [ "1 핵심 요약", "재현", "2장 표에서 계산" ],
    [ "2.1 판정 결과 분포 · 2.2 연도별", "재현", "result·year 집계" ],
    [ "2.3 신청서 종류·사망자 결정", "재현(정규화 뒤 분포)", "옛 표기 원문은 `*_detail`에 일부만 남아 옛 표와 직접 비교 불가" ],
    [ "3 업무관련성 × 판정", "재현", "work_relevance_eval 집계" ],
    [ "4.1·4.2 직종", "재현", "job_name 집계(빈값·`-` 제외). 동률 순서는 이름순" ],
    [ "4.3 근무 형태", "재현(정규화 뒤 분포)", "옛 표기 원문은 덮어써져 복원 불가" ],
    [ "5.1 질병군 · 5.2 신체부위", "재현", "disease_category·body_part 집계" ],
    [ "5.3 상병군(정규화)", "재현 불가", "부위·질병 계열로 접는 규칙(wc/normalize.py)이 저장소에 없다" ],
    [ "5.4 정규화된 상병 순위", "근사 재현", "공백 제거 + 맨 앞 좌/우/양(측) 제거. 원 스크립트가 없어 일부 행이 다를 수 있다" ],
    [ "6.1 근거 유형 · 6.2 신체부담 요인 · 6.4 평가 수준 · 6.5 불인정 사유", "재현 불가", "정규식·키워드 목록이 문서에도 저장소에도 없다" ],
    [ "6.3 신체부위 × 신체부담 부위", "재현", "body_part × burden_body_part(파이프 토큰)" ],
    [ "7 일부인정", "재현", "7.1 사례 예시와 8장 대표 사례는 통계가 아니라 제외" ]
  ].freeze

  def initialize(scope: DiseaseCase.all, generated_on: Date.today)
    @scope = scope
    @generated_on = generated_on
  end

  def to_markdown
    result = nil
    ActiveRecord::Base.while_preventing_writes { result = build }
    result
  end

  private

  def build
    @total = @scope.count
    parts = [ header, reproducibility, summary, section_2, section_3, section_4, section_5, section_6, section_7 ]
    parts.join("\n\n") + "\n"
  end

  # ---- 공용 ----

  def results_by(column, rows = nil)
    @scope.group(column, :result).count.each_with_object(Hash.new { |h, k| h[k] = Hash.new(0) }) do |((key, result), n), acc|
      acc[key][result] += n
    end.then { |h| rows ? h.slice(*rows) : h }
  end

  def total_of(counts) = counts.values.sum

  def pct(num, den, digits = 1)
    den.zero? ? "-" : format("%.#{digits}f%%", num * 100.0 / den)
  end

  def n(value) = value.to_s.reverse.scan(/\d{1,3}/).join(",").reverse

  def table(headers, rows)
    lines = [ "| #{headers.join(' | ')} |", "|#{headers.map { '---' }.join('|')}|" ]
    rows.each { |row| lines << "| #{row.map { |c| c.to_s.gsub('|', '\\|') }.join(' | ')} |" }
    lines.join("\n")
  end

  def label(value) = value.presence || BLANK

  # 인정률 = 인정 / 전체, 일부포함 = (인정 + 일부인정 + 변경인정) / 전체, 불인정률 = 불인정 / 전체(2.1 정의와 같다)
  def rate_cells(counts, digits)
    total = total_of(counts)
    [ pct(counts["approved"], total, digits),
      pct(counts["approved"] + counts["partially_approved"] + counts["revised_approved"], total, digits),
      pct(counts["rejected"], total, digits) ]
  end

  # ---- 머리말 ----

  def header
    <<~MD.chomp
      # 판정서 분석 통계표(재생성)

      - 생성일: #{@generated_on} · 대상: `disease_cases` #{n(@total)}건 · 판정일 #{@scope.minimum(:decided_on)} ~ #{@scope.maximum(:decided_on)}
      - 방법: 로컬 DB 질의만 사용(읽기 전용, LLM·외부 API 없음). 스크립트는 `lib/tasks/analysis.rake`, 구현은 `app/models/analysis_report.rb`.
      - 번호는 `wip/workercare-hermes.md` [A]의 절 번호와 같다. 규칙을 알 수 없는 표는 만들지 않고 "재현 불가"로 적는다.
      - 추출 컬럼(직종·업무관련성·부담 부위 등)은 LLM이 뽑은 값이라 틀릴 수 있다.
    MD
  end

  def reproducibility
    "## 재현 가능성\n\n" + table(%w[절 상태 비고], REPRODUCIBILITY)
  end

  # ---- 1·2 ----

  def summary
    counts = @scope.group(:result).count
    deaths = @scope.where(death_status: "Y").count
    rows = [ [ "전체 판정 사례", "#{n(@total)}건" ] ]
    RESULT_KO.each { |key, ko| rows << [ ko, "#{pct(counts[key].to_i, @total, 2)} (#{n(counts[key].to_i)}건)" ] }
    positive = counts["approved"].to_i + counts["partially_approved"].to_i + counts["revised_approved"].to_i
    rows << [ "인정(일부인정·변경인정 포함) 비율", pct(positive, @total, 2) ]
    rows << [ "사망자 결정(death_status=Y)", "#{n(deaths)}건 (#{pct(deaths, @total, 2)})" ]
    "## 1. 핵심 요약\n\n" + table(%w[지표 값], rows)
  end

  def section_2
    counts = @scope.group(:result).count
    dist = RESULT_KO.map { |key, ko| [ ko, n(counts[key].to_i), pct(counts[key].to_i, @total, 2) ] }

    by_year = results_by(:year)
    years = by_year.keys.compact.sort.map do |year|
      c = by_year[year]
      [ "#{year}년", n(total_of(c)), n(c["approved"]), n(c["partially_approved"]), n(c["revised_approved"]), n(c["rejected"]),
        pct(c["approved"], total_of(c), 2), pct(c["approved"] + c["partially_approved"] + c["revised_approved"], total_of(c), 2) ]
    end
    nil_year = by_year[nil]
    years << [ "(연도 없음)", n(total_of(nil_year)), "", "", "", "", "", "" ] if nil_year&.any?

    types = @scope.group(:application_type).count.sort_by { |k, v| [ -v, k.to_s ] }
                  .map { |k, v| [ label(k), n(v), pct(v, @total, 2) ] }
    deaths = @scope.group(:death_status).count.sort_by { |k, v| [ -v, k.to_s ] }
                   .map { |k, v| [ label(k), n(v), pct(v, @total, 2) ] }

    <<~MD.chomp
      ## 2. 수집 데이터 구성

      ### 2.1 판정 결과 분포

      #{table(%w[심의결과 건수 비율], dist)}

      ### 2.2 연도별 분포

      #{table(%w[심의연도 전체 인정 일부인정 변경인정 불인정 인정률 인정률(일부포함)], years)}

      ### 2.3 신청서 종류 및 사망자 결정

      `application_type`은 정규화 뒤 값이다(`|`로 이은 복수 값은 그대로 한 행). 빈 값은 `-`로 적는다.

      #{table(%w[신청서\ 종류 건수 비율], types)}

      #{table(%w[death_status 건수 비율], deaths)}
    MD
  end

  # ---- 3 ----

  def section_3
    by = results_by(:work_relevance_eval)
    keys = RELEVANCE_ORDER + [ nil ]
    rows = keys.filter_map do |key|
      c = by[key]
      next if c.empty?
      total = total_of(c)
      [ label(key).tr("_", " "), n(total), n(c["approved"]), n(c["partially_approved"]), n(c["rejected"]),
        pct(c["approved"], total, 2), pct(c["rejected"], total, 2) ]
    end
    "## 3. 업무관련성 평가와 판정 결과\n\n" + table(%w[업무관련성 전체 인정 일부인정 불인정 인정률 불인정률], rows)
  end

  # ---- 4 ----

  def job_rows(limit)
    by = results_by(:job_name)
    by.delete(nil)
    by.delete("")
    by.delete("-")
    by.map { |name, c| [ name, total_of(c), c ] }
      .sort_by { |name, total, _| [ -total, name ] }.first(limit)
  end

  def section_4
    top40 = job_rows(40)
    rows40 = top40.map { |name, total, c| [ name, n(total), *rate_cells(c, 1) ] }
    top30 = top40.first(30)
    ranked = top30.sort_by { |name, _, c| [ -c["approved"].fdiv(c.values.sum), name ] }
    fmt = ->(list) { list.map { |name, total, c| [ name, n(total), *rate_cells(c, 1) ] } }
    heads = %w[직종 건수 인정률 인정률(일부포함) 불인정률]

    types = results_by(:work_type)
    work = types.map { |name, c| [ name, total_of(c), c ] }.sort_by { |name, total, _| [ -total, name.to_s ] }
                .map { |name, total, c| [ label(name), n(total), pct(c["approved"], total), pct(c["rejected"], total) ] }

    <<~MD.chomp
      ## 4. 직종별 인정률

      직종은 `job_name` 값 그대로 집계한다(표기 변형이 합쳐지지 않는다). 빈 값과 `-`는 뺀다. 일부포함은 인정·일부인정·변경인정의 합이다.

      ### 4.1 판정 사례 누적 상위 40개 직종

      #{table(%w[직종 건수 인정률 인정률(일부포함) 불인정률], rows40)}

      ### 4.2 상위 30개 직종에서 인정률 상·하위

      **인정률 상위**

      #{table(heads, fmt.call(ranked.first(8)))}

      **인정률 하위**

      #{table(heads, fmt.call(ranked.last(8).reverse))}

      ### 4.3 근무 형태별

      `work_type`은 정규화 뒤 범주다(부가 표기는 `work_type_detail`). 옛 원문 표기별 표와는 비교되지 않는다.

      #{table(%w[근무\ 형태 건수 인정률 불인정률], work)}
    MD
  end

  # ---- 5 ----

  def section_5
    cat = results_by(:disease_category)
    cat_rows = cat.map { |k, c| [ k, total_of(c), c ] }.sort_by { |k, total, _| [ k.nil? ? 1 : 0, -total, k.to_s ] }.map do |k, total, c|
      [ CATEGORY_KO.fetch(k, label(k)), n(total), pct(total, @total, 2), n(c["approved"]), n(c["partially_approved"]),
        n(c["rejected"]), pct(c["approved"], total) ]
    end

    bp = results_by(:body_part)
    bp_rows = bp.map { |k, c| [ k, total_of(c), c ] }.sort_by { |k, total, _| [ k.nil? ? 1 : 0, -total, k.to_s ] }.map do |k, total, c|
      [ BODY_PART_KO.fetch(k, label(k)), n(total), n(c["approved"]), n(c["partially_approved"]), n(c["rejected"]),
        pct(c["approved"], total), pct(c["rejected"], total) ]
    end

    <<~MD.chomp
      ## 5. 질병군·신체부위별 분포

      ### 5.1 질병군

      비율은 전체 건수 기준이다. `-`는 질병군이 비어 있는 행이다.

      #{table(%w[질병군 건수 비율 인정 일부인정 불인정 인정률], cat_rows)}

      ### 5.2 신청 상병 부위 (사이트 분류 기준)

      `-`는 body_part가 비어 있는 행이다.

      #{table(%w[부위 건수 인정 일부인정 불인정 인정률 불인정률], bp_rows)}

      ### 5.3 상병군별 분포 (정규화)

      **재현 불가.** 원문 상병 표기를 부위·질병 계열(허리_근골격, 심장_혈관 …)로 접는 규칙이 `wc/normalize.py`에만 있었고 저장소에 없다. 규칙을 임의로 만들면 옛 표와 비교가 무의미해지므로 만들지 않았다.

      #{disease_name_table}
    MD
  end

  # 5.4: 공백을 모두 지우고 맨 앞의 좌측·우측·양측(및 한 글자 좌·우·양)을 뗀 상병명으로 묶는다.
  def disease_name_table
    groups = Hash.new { |h, k| h[k] = [ 0, 0, 0 ] }
    covered = 0
    @scope.where.not(disease_name: [ nil, "" ]).pluck(:disease_name, :result).each do |name, result|
      key = name.gsub(/\s+/, "").sub(/\A(좌측|우측|양측|좌|우|양)/, "")
      next if key.empty?
      covered += 1
      g = groups[key]
      g[0] += 1
      g[1] += 1 if result == "approved"
      g[2] += 1 if result == "rejected"
    end
    rows = groups.sort_by { |k, v| [ -v[0], k ] }.first(30).map do |k, (total, approved, rejected)|
      [ k, n(total), n(approved), n(rejected), pct(approved, total) ]
    end

    "### 5.4 정규화된 상병 다발 순위 (근사 재현)\n\n" \
      "규칙: 공백 제거, 맨 앞 좌측·우측·양측(좌·우·양) 제거, `/`로 이은 복수 상병은 한 덩어리로 둔다. " \
      "대상 #{n(covered)}건, 서로 다른 상병 #{n(groups.size)}종. 원 스크립트가 없어 옛 표와 일부 행이 다를 수 있다.\n\n" +
      table(%w[상병(정규화) 건수 인정 불인정 인정률], rows)
  end

  # ---- 6 ----

  def section_6
    "## 6. 인정·불인정 논리 구조 (전문 텍스트 마이닝)\n\n" \
      "### 6.1 · 6.2 · 6.4 · 6.5\n\n" \
      "**재현 불가.** 결론·주문·인정사실 텍스트에서 \"상당인과관계_인정\", \"무리한힘\", \"노령_자연경과\" 같은 유형을 뽑은 정규식·키워드 목록이 " \
      "문서(방법론 10.2는 \"정규식 추출\"이라고만 적었다)에도 저장소에도 없다. 규칙을 새로 정하면 같은 표가 아니므로 만들지 않았다. " \
      "필요하면 규칙을 정해 문서에 적은 뒤 이 보고서에 더한다.\n\n" +
      section_6_3
  end

  def section_6_3
    rows = @scope.pluck(:body_part, :burden_body_part, :result)
    buckets = Hash.new do |h, k|
      h[k] = { rows: 0, tok_rows: 0, tokens: 0, dist: Hash.new { |hh, t| hh[t] = [ 0, 0, 0 ] }, res: Hash.new(0) }
    end
    token_total = Hash.new(0)
    split_by_token = Hash.new { |h, t| h[t] = Hash.new(0) }

    rows.each do |body_part, burden, result|
      bp = body_part.presence ? BODY_PART_KO.fetch(body_part, body_part) : NO_BODY_PART
      tokens = burden.to_s.split("|").map(&:strip).reject(&:empty?)
      b = buckets[bp]
      b[:rows] += 1
      b[:res][result] += 1
      next b[:rows] if tokens.empty?
      b[:tok_rows] += 1
      b[:tokens] += tokens.size
      tokens.each do |t|
        d = b[:dist][t]
        d[0] += 1
        d[1] += 1 if result == "approved"
        d[2] += 1 if result == "rejected"
        token_total[t] += 1
        split_by_token[t][bp] += 1
      end
    end

    ordered = buckets.keys.reject { |k| k == NO_BODY_PART }.sort_by { |k| [ -buckets[k][:rows], k ] }
    ordered << NO_BODY_PART if buckets.key?(NO_BODY_PART)
    recorded = ordered - [ NO_BODY_PART ]
    recorded_rows = recorded.sum { |k| buckets[k][:rows] }
    recorded_tok = recorded.sum { |k| buckets[k][:tok_rows] }
    none = buckets[NO_BODY_PART]
    all_tok_rows = buckets.values.sum { |b| b[:tok_rows] }

    cover = table([ "", "부담 부위 토큰 있음", "토큰 없음", "합" ], [
      [ "신체부위 기록 있음", n(recorded_tok), n(recorded_rows - recorded_tok), n(recorded_rows) ],
      [ "신체부위 미기록", n(none ? none[:tok_rows] : 0), n(none ? none[:rows] - none[:tok_rows] : 0), n(none ? none[:rows] : 0) ],
      [ "합", n(all_tok_rows), n(@total - all_tok_rows), n(@total) ]
    ])
    summary_rows = ordered.map do |k|
      b = buckets[k]
      [ k, n(b[:rows]), n(b[:res]["approved"]), n(b[:res]["partially_approved"]), n(b[:res]["revised_approved"]),
        n(b[:res]["rejected"]), n(b[:rows] - b[:tok_rows]), n(b[:tokens]), n(b[:dist].size) ]
    end

    out = [ "### 6.3 신체부위 × 신체부담 부위 (계층 통계)\n\n" \
            "`body_part` × `burden_body_part`(파이프 `|` 경계 토큰) × result 전수 교차 집계다. 건수는 토큰 출현 횟수이고 " \
            "인정률은 인정 ÷ 건수다. 토큰 출현 합계 #{n(buckets.values.sum { |b| b[:tokens] })}건, 토큰 종 #{n(token_total.size)}종.",
            "#### 6.3.1 신체부위 단계 요약\n\n#{cover}",
            table(%w[신체부위 행\ 수 인정 일부인정 변경인정 불인정 토큰\ 없는\ 행 토큰\ 출현 토큰\ 종], summary_rows) ]

    ordered.each_with_index do |bp, i|
      b = buckets[bp]
      next if b[:dist].empty?
      sorted = b[:dist].sort_by { |t, v| [ -v[0], t ] }
      top = sorted.first(TOP_TOKENS)
      rest = sorted.drop(TOP_TOKENS)
      trs = top.map { |t, (c, a, r)| [ t, n(c), n(a), n(r), pct(a, c) ] }
      if rest.any?
        rc = rest.sum { |_, v| v[0] }
        ra = rest.sum { |_, v| v[1] }
        trs << [ "그 외", "#{n(rest.size)}종, #{n(rc)}건", n(ra), n(rest.sum { |_, v| v[2] }), pct(ra, rc) ]
      end
      title = bp == NO_BODY_PART ? "#{bp} 행의 부담 부위 — #{n(b[:rows])}행(토큰 있는 행 #{n(b[:tok_rows])}행)" : "#{bp} — #{n(b[:rows])}행"
      out << "#### 6.3.#{i + 2} #{title}\n\n" + table(%w[부담\ 부위 건수 인정 불인정 인정률], trs)
    end

    decomposition = DECOMPOSED_TOKENS.filter_map do |t|
      next unless token_total[t].positive?
      parts = split_by_token[t].sort_by { |k, v| [ -v, k ] }.map { |k, v| "#{k == NO_BODY_PART ? '값없음' : k} #{n(v)}" }
      "- #{t} #{n(token_total[t])} = #{parts.join(' + ')}"
    end
    out << "상위 토큰의 부위별 분해(전체 건수 = 부위별 분배 합):\n#{decomposition.join("\n")}" if decomposition.any?
    out.join("\n\n")
  end

  # ---- 7 ----

  def section_7
    partial = @scope.where(result: "partially_approved")
    by_year = @scope.group(:year).count
    year_rows = partial.group(:year).count.sort_by { |y, _| y.to_i }.map do |y, c|
      [ y ? "#{y}년" : "(연도 없음)", n(c), pct(c, by_year[y].to_i, 1) ]
    end
    cat_rows = partial.group(:disease_category).count.sort_by { |k, v| [ -v, k.to_s ] }
                      .map { |k, v| [ CATEGORY_KO.fetch(k, label(k)), n(v) ] }

    "## 7. 일부인정 구조 분석\n\n일부인정 #{n(partial.count)}건(#{pct(partial.count, @total)}).\n\n" \
      "#{table(%w[심의연도 일부인정\ 건수 해당\ 연도\ 대비\ 비율], year_rows)}\n\n" \
      "**일부인정 사례의 질병군 분포**\n\n#{table(%w[질병군 일부인정\ 건수], cat_rows)}"
  end
end
