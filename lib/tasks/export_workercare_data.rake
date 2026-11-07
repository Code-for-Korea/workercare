# frozen_string_literal: true

require "csv"

namespace :export do
  desc "판정서·KSCO 데이터를 CSV로 내보내고 데이터 사전을 만든다. 사용법: rails 'export:workercare_data[YYYYMMDD]' (날짜 생략 시 오늘). 정규화 백필 전 백업에도 쓴다."
  task :workercare_data, [ :date ] => :environment do |_, args|
    export_date = (args[:date].presence || Date.current.strftime("%Y%m%d")).to_s
    unless export_date.match?(/\A\d{8}\z/) && Date.valid_date?(export_date[0, 4].to_i, export_date[4, 2].to_i, export_date[6, 2].to_i)
      abort "날짜는 유효한 YYYYMMDD 형식이어야 합니다: #{export_date}"
    end

    output_dir = Rails.root.join("tmp")
    FileUtils.mkdir_p(output_dir)

    disease_case_columns = DiseaseCase.column_names
    ksco_code_columns = KscoCode.column_names
    mapping_columns = DiseaseCaseKscoCode.column_names

    files = {
      disease_cases: output_dir.join("disease_cases_#{export_date}.csv"),
      dictionary: output_dir.join("workercare_data_dictionary_#{export_date}.md")
    }
    ksco_available = DiseaseCaseKscoCode.exists? && KscoCode.exists?
    if ksco_available
      files[:ksco_codes] = output_dir.join("ksco_codes_#{export_date}.csv")
      files[:disease_case_ksco_codes] = output_dir.join("disease_case_ksco_codes_#{export_date}.csv")
    else
      # 이전 실행에서 생성된 KSCO 파일이 남아 있으면 현재 스냅샷과 혼동될 수 있다.
      FileUtils.rm_f(output_dir.join("ksco_codes_#{export_date}.csv"))
      FileUtils.rm_f(output_dir.join("disease_case_ksco_codes_#{export_date}.csv"))
    end

    write_csv(files[:disease_cases], disease_case_columns, DiseaseCase.order(:id))
    if ksco_available
      write_csv(files[:ksco_codes], ksco_code_columns, KscoCode.order(:code))
      write_csv(files[:disease_case_ksco_codes], mapping_columns, DiseaseCaseKscoCode.order(:id))
    end
    write_dictionary(files, export_date, disease_case_columns, ksco_code_columns, mapping_columns, ksco_available)

    puts "추출 완료 (#{export_date})"
    files.each_value { |path| puts "- #{path.relative_path_from(Rails.root)}" }
    puts "건수: disease_cases=#{DiseaseCase.count}, ksco_codes=#{KscoCode.count}, disease_case_ksco_codes=#{DiseaseCaseKscoCode.count}"
    puts "KSCO 추출: #{ksco_available ? '포함' : '제외 (연결 데이터 없음)'}"
  end

  def write_csv(path, columns, relation)
    CSV.open(path, "wb", write_headers: true, headers: columns, encoding: "UTF-8") do |csv|
      relation.find_each(batch_size: 1_000) do |record|
        csv << columns.map { |column| record.public_send(column) }
      end
    end
  end

  def write_dictionary(files, export_date, disease_case_columns, ksco_code_columns, mapping_columns, ksco_available)
    disease_case_descriptions = {
      "id" => "내부 데이터베이스 식별자",
      "case_no" => "산재 질병 사례 번호. 공개 링크와 사례 식별에 사용",
      "disease_name" => "질병명",
      "result" => "심의 결과. approved(인정), rejected(불인정), partially_approved(일부 인정), revised_approved(변경 인정)",
      "year" => "심의 연도",
      "disease_category" => "질병 대분류. musculoskeletal, other_disease, hearing_loss, cardiovascular, cancer, pneumoconiosis, respiratory 중 하나",
      "body_part" => "주요 부담 신체 부위 분류",
      "link" => "원문 또는 원출처 링크",
      "statement" => "신청 사건의 판정서/사건 개요 원문",
      "claim_purpose" => "신청 취지 원문",
      "application_content" => "신청 내용 원문",
      "applicant_claim" => "신청인 주장 원문",
      "medical_records" => "의학적 소견·의무기록 관련 원문",
      "recognized_facts" => "심의 과정에서 인정된 사실 원문",
      "related_laws" => "관련 법령·기준 원문",
      "committee_decision" => "위원회 판단·결정 원문",
      "decided_on" => "심의 결정일",
      "created_at" => "데이터베이스 레코드 생성 시각",
      "updated_at" => "데이터베이스 레코드 최종 수정 시각",
      "job_name" => "사례에서 추출한 직업명",
      "job_description" => "사례에서 추출한 직업·업무 설명",
      "employment_type" => "고용 형태(정규화). 정규직·상용직·일용직·계약직·파견직·특수고용·프리랜서·자영업·기타",
      "work_type" => "근무 형태(정규화). 고정주간근무·교대근무·야간근무·격일근무·시간제근무·일용근무·기타",
      "job_tenure_months" => "해당 직업 종사 기간(개월) 추출값",
      "weekly_work_hours" => "주당 근로시간 추출값",
      "daily_work_hours" => "일일 근로시간 추출값",
      "burden_body_part" => "업무 부담이 발생한 신체 부위 추출값",
      "bad_posture" => "부담 자세·부적절한 작업 자세 추출값",
      "heavy_lifting" => "중량물 취급 여부. Y·N 중 하나, 값이 없으면 NULL",
      "max_item_weight" => "취급 물품 최대 중량 추출값",
      "daily_total_weight" => "일일 총 취급 중량 추출값",
      "other_harmful_factors" => "기타 유해·위험 요인 추출값",
      "work_relevance_eval" => "업무와 질병의 관련성 평가. 매우_높음·높음·보통·낮음·매우_낮음·미흡 중 하나, 값이 없으면 NULL",
      "aggravating_factors" => "질병을 악화시킨 요인 추출값",
      "main_reasoning" => "판정의 주요 근거 요약 추출값",
      "death_status" => "사망 여부. Y·N 중 하나, 값이 없으면 NULL",
      "application_type" => "신청 유형(정규화). 요양급여·휴업급여·유족급여·장의비·추가상병·장해급여·미지급보험급여·재신청·기타를 `\\|`로 결합",
      "application_type_detail" => "신청 유형을 정규화하며 따로 보존한 괄호 수식어·원문",
      "work_type_detail" => "근무 형태를 범주로 정규화하며 따로 보존한 시간·근무일수 등 세부 표기",
      "employment_type_detail" => "고용 형태를 범주로 정규화하며 따로 보존한 괄호 수식어·세부 표기"
    }

    ksco_descriptions = {
      "code" => "한국표준직업분류(KSCO) 직업 코드. 이 테이블의 기본키",
      "name" => "KSCO 직업명",
      "minor" => "KSCO 소분류명",
      "submajor" => "KSCO 중분류명",
      "major" => "KSCO 대분류명",
      "job_examples" => "해당 분류에 포함되는 직업 예시",
      "exclusions" => "해당 분류에서 제외되는 직업·범위"
    }

    mapping_descriptions = {
      "id" => "연결 레코드 식별자",
      "disease_case_id" => "disease_cases.id를 참조하는 사례 식별자",
      "ksco_code_id" => "ksco_codes.code를 참조하는 KSCO 코드",
      "similarity" => "사례와 KSCO 직업의 매칭 유사도. 산출 방법과 기준은 별도 처리 문서 참조"
    }

    job_filled = DiseaseCase.where.not(job_name: [ nil, "" ]).count
    job_rate = DiseaseCase.count.zero? ? 0.0 : job_filled.fdiv(DiseaseCase.count) * 100
    counts = {
      disease_cases: DiseaseCase.count,
      ksco_codes: KscoCode.count,
      disease_case_ksco_codes: DiseaseCaseKscoCode.count
    }
    db_tables = ActiveRecord::Base.connection.tables.sort
    fts_tables = %w[disease_cases_fts disease_cases_extracted_fts].select do |table|
      ActiveRecord::Base.connection.select_value("SELECT COUNT(*) FROM #{ActiveRecord::Base.connection.quote_table_name(table)}")
      true
    rescue ActiveRecord::StatementInvalid
      false
    end
    table_purposes = {
      "disease_cases" => "산재 질병 심의 사례 본체 데이터 — 추출 대상",
      "ksco_codes" => ksco_available ? "한국표준직업분류 마스터 — 추출 대상" : "한국표준직업분류 마스터 — 연결 데이터가 없어 이번 추출에서 제외",
      "disease_case_ksco_codes" => ksco_available ? "사례-KSCO 연결 데이터 — 추출 대상" : "사례-KSCO 연결 데이터 — 0건이라 이번 추출에서 제외",
      "disease_cases_fts" => "원문 검색용 SQLite FTS 파생 인덱스 — 원본 사례 CSV에서 재생성 가능",
      "disease_cases_extracted_fts" => "추출 컬럼 검색용 SQLite FTS 파생 인덱스 — 원본 사례 CSV에서 재생성 가능",
      "schema_migrations" => "Rails 마이그레이션 적용 이력 — 메타데이터",
      "ar_internal_metadata" => "Rails 환경 메타데이터"
    }

    lines = []
    lines << "# Workercare 데이터 추출 컬럼 설명"
    lines << ""
    lines << "## 1. 문서 목적과 데이터 범위"
    lines << ""
    lines << "이 문서는 Workercare 데이터베이스에서 추출한 CSV를 처음 다루는 분석자가 파일의 단위, 컬럼 의미, 테이블 관계, 결측값과 분석상의 주의사항을 이해할 수 있도록 작성한 데이터 사전이다. CSV는 분석용으로 별도 변환한 데이터가 아니라, 추출 시점의 데이터베이스 값을 그대로 저장한 스냅샷이다."
    lines << ""
    lines << "- 기준일: `#{export_date[0, 4]}-#{export_date[4, 2]}-#{export_date[6, 2]}`"
    lines << "- 생성 환경: `#{Rails.env}`"
    lines << "- 추출 명령: `bin/rails export:workercare_data[#{export_date}]`"
    lines << "- 추출 원칙: 데이터베이스 값을 변환·마스킹하지 않고 CSV로 내보냄. 단 `application_type`, `work_type`, `employment_type`은 DB에 저장된 시점에 이미 정규화된 값이며, 정규화 전 표기는 `*_detail` 컬럼에만 일부 남아 있음(규칙: `docs/disease-cases-normalization.md`)"
    lines << "- 문자 인코딩: UTF-8. 셀 안의 쉼표, 줄바꿈, 큰따옴표는 CSV 규칙에 따라 인용 처리됨"
    lines << "- 개인정보 주의: `disease_cases`의 판정서 관련 컬럼에는 원문 또는 개인정보가 포함될 수 있으므로 외부 공유 전 별도 비식별 검수가 필요함"
    lines << "- 직업 데이터 판단: `disease_cases` 내부의 직업·업무 추출 컬럼은 주요 컬럼이 약 #{format('%.1f', job_rate)}% 채워져 있어 유지함. #{ksco_available ? 'KSCO 마스터와 사례 연결 데이터도 함께 추출함' : '별도 KSCO 데이터는 연결 행이 0건이라 CSV에서 제외함'}"
    lines << ""
    lines << "## 2. DB 전체 점검 결과"
    lines << ""
    lines << "Rails 개발 데이터베이스의 모든 테이블을 확인했다. 아래 표에서 `추출 여부`가 ‘추출’인 테이블만 분석 CSV로 생성한다. 세션·메시지 테이블은 모두 0건인 운영 저장소이거나, 데이터가 있더라도 사례 분석 데이터가 아니므로 본 추출 범위에서 제외한다."
    lines << ""
    lines << "| 테이블 | 행 수 | 추출 여부 | 용도/판단 |"
    lines << "|---|---:|---|---|"
    db_tables.each do |table|
      row_count = ActiveRecord::Base.connection.select_value("SELECT COUNT(*) FROM #{ActiveRecord::Base.connection.quote_table_name(table)}").to_i
      included = table == "disease_cases" || (ksco_available && %w[ksco_codes disease_case_ksco_codes].include?(table))
      status = included ? "추출" : "제외"
      purpose = table_purposes.fetch(table, "Rails/애플리케이션 내부 테이블")
      lines << "| `#{table}` | #{row_count.to_fs(:delimited)} | #{status} | #{purpose} |"
    end
    fts_tables.each do |table|
      row_count = ActiveRecord::Base.connection.select_value("SELECT COUNT(*) FROM #{ActiveRecord::Base.connection.quote_table_name(table)}").to_i
      lines << "| `#{table}` | #{row_count.to_fs(:delimited)} | 제외 | #{table_purposes.fetch(table)} |"
    end
    lines << "| SQLite FTS shadow tables/triggers | — | 제외 | FTS 내부 저장 구조(`*_data`, `*_idx`, `*_docsize`, `*_config`)와 유지보수용 trigger/index — 분석용 원본이 아님 |"
    lines << "| SQLite sequence/index 및 Rails 메타데이터 | — | 제외 | 자동 증가·인덱스·마이그레이션 관리용 내부 객체 |"
    lines << ""
    lines << "### 직업 데이터 포함·제외 판단"
    lines << ""
    lines << "- 포함: `disease_cases`의 `job_name`, `job_description`, `employment_type`, `work_type`, 근로시간·중량·유해요인·업무 관련성 등 추출 컬럼. `job_name` 등 핵심 필드는 #{counts[:disease_cases].to_fs(:delimited)}건 중 #{job_filled.to_fs(:delimited)}건(#{format('%.1f', job_rate)}%)에 값이 있어 ‘거의 비어 있음’으로 보지 않았다."
    if ksco_available
      lines << "- 포함: `ksco_codes` #{counts[:ksco_codes].to_fs(:delimited)}건과 `disease_case_ksco_codes` 연결 #{counts[:disease_case_ksco_codes].to_fs(:delimited)}건. 연결은 자동 추정(임베딩 유사도 상위 5개)이며 사람이 검증하지 않았다."
    else
      lines << "- 제외: `ksco_codes`는 #{counts[:ksco_codes].to_fs(:delimited)}건뿐이고, `disease_case_ksco_codes` 연결 행은 0건이다. 따라서 현재 스냅샷에서는 KSCO별 사례 분석이 불가능하다."
      lines << "- 재추출 시 연결 데이터가 1건 이상 생기면 Rake 작업이 KSCO 마스터와 연결 CSV를 자동으로 다시 포함한다."
    end
    lines << ""
    lines << "### 분석 단위(grain)"
    lines << ""
    lines << "| 파일 | 한 행의 의미 | 기본 식별자 | 현재 행 수 |"
    lines << "|---|---|---|---:|"
    lines << "| `disease_cases_#{export_date}.csv` | 산재 질병 사례 1건 | `id`(내부 키), `case_no`(사례 번호) | #{counts[:disease_cases].to_fs(:delimited)} |"
    if ksco_available
      lines << "| `ksco_codes_#{export_date}.csv` | KSCO 직업분류 코드 1건 | `code` | #{counts[:ksco_codes].to_fs(:delimited)} |"
      lines << "| `disease_case_ksco_codes_#{export_date}.csv` | 사례 1건과 KSCO 코드 1개의 연결 1건 | `id`; 조합 `disease_case_id` + `ksco_code_id` | #{counts[:disease_case_ksco_codes].to_fs(:delimited)} |"
    end
    lines << ""
    if counts[:disease_case_ksco_codes].zero?
      lines << "현재 추출 시점에는 사례-KSCO 연결 행이 `0`건이므로, 사례 CSV와 KSCO CSV를 조인해도 연결된 직업분류 결과는 나오지 않는다. 이는 CSV 추출 누락이 아니라 현재 연결 테이블의 상태다."
    else
      lines << "사례 1건에 KSCO 후보가 여러 개 연결될 수 있으므로, 조인하면 사례 행이 늘어난다. 사례 수를 셀 때는 `DISTINCT case_no`를 쓴다."
    end
    lines << ""
    lines << "## 3. 테이블 관계와 조인 방법"
    lines << ""
    lines << "```text"
    lines << "disease_cases (1) ──< disease_case_ksco_codes >── (1) ksco_codes"
    lines << "```"
    lines << ""
    lines << "- `disease_cases.id = disease_case_ksco_codes.disease_case_id`로 사례와 연결 행을 조인한다."
    lines << "- `ksco_codes.code = disease_case_ksco_codes.ksco_code_id`로 연결 행과 KSCO 분류를 조인한다."
    lines << "- 사례별 KSCO 코드를 보고 싶다면 연결 테이블을 기준으로 조인한다. 연결 행이 없는 사례도 포함하려면 `LEFT JOIN`을 사용한다."
    lines << "- `disease_cases.case_no`는 사람이 보는 사례 번호이고, 연결 테이블은 내부 숫자 키인 `disease_case_id`를 사용한다. 두 값을 혼동하지 않는다."
    lines << ""
    lines << "예시(SQL/SQLite 또는 DuckDB):"
    lines << ""
    lines << "```sql"
    lines << "SELECT"
    lines << "  dc.case_no, dc.disease_name, dc.result,"
    lines << "  kc.code AS ksco_code, kc.name AS ksco_name, dck.similarity"
    lines << "FROM disease_cases AS dc"
    lines << "LEFT JOIN disease_case_ksco_codes AS dck ON dck.disease_case_id = dc.id"
    lines << "LEFT JOIN ksco_codes AS kc ON kc.code = dck.ksco_code_id;"
    lines << "```"
    lines << ""
    lines << "CSV를 DuckDB에서 읽는 예시:"
    lines << ""
    lines << "```sql"
    lines << "SELECT result, COUNT(*) AS case_count"
    lines << "FROM read_csv_auto('disease_cases_#{export_date}.csv')"
    lines << "GROUP BY result ORDER BY case_count DESC;"
    lines << "```"
    lines << ""
    lines << "## 생성 파일"
    lines << ""
    files.each do |name, path|
      next if name == :dictionary
      lines << "- `#{path.basename}` — #{counts.fetch(name).to_fs(:delimited)}건"
    end
    lines << ""
    lines << "## 4. 분석을 시작할 때의 권장 순서"
    lines << ""
    lines << "1. 먼저 `disease_cases`에서 `case_no`, `disease_name`, `result`, `year`, `decided_on`으로 사례 수와 기간을 확인한다."
    lines << "2. `result`의 값별 건수와 결측률을 확인한다. 결과값이 비어 있는 사례를 승인/불인정 그룹에 임의로 포함하지 않는다."
    lines << "3. 원문 필드와 추출 필드를 구분한다. 원문은 근거 확인용이고, `job_*`, `main_reasoning` 등은 검색·요약을 위한 분석 보조값이다."
    lines << "4. 직업별 분석이 필요할 때만 연결 테이블을 사용한다. #{counts[:disease_case_ksco_codes].zero? ? '현재 스냅샷은 연결 행이 0건이므로 KSCO별 분석은 수행할 수 없다.' : '연결은 자동 추정이므로 유사도를 함께 확인한다.'}"
    lines << "5. 결론을 보고할 때는 분석 대상 기간, 결과 결측 제외 여부, 원문/추출 필드 사용 여부를 함께 기록한다."
    lines << ""
    lines << "## `disease_cases_#{export_date}.csv`"
    lines << ""
    lines << "사례 데이터의 한 행은 산재 질병 심의 사례 1건이다. 이 파일이 주요 분석 대상이며, 판정 결과와 사건 원문, 업무·유해요인 추출값을 함께 포함한다."
    lines << ""
    lines.concat(column_table(disease_case_columns, DiseaseCase, disease_case_descriptions))
    lines << ""
    if ksco_available
      lines << "## `ksco_codes_#{export_date}.csv`"
      lines << ""
      lines << "KSCO 직업분류 마스터다. `code`가 기본키이며, 사례와 직접 연결되지 않고 연결 테이블을 통해서만 사용된다."
      lines << ""
      lines.concat(column_table(ksco_code_columns, KscoCode, ksco_descriptions))
      lines << ""
      lines << "## `disease_case_ksco_codes_#{export_date}.csv`"
      lines << ""
      lines << "사례와 KSCO 직업 코드의 다대다 연결 테이블이다. `disease_case_id`와 `ksco_code_id`를 이용해 두 기본 CSV와 조인한다."
      lines << ""
      lines.concat(column_table(mapping_columns, DiseaseCaseKscoCode, mapping_descriptions))
      lines << ""
    end
    lines << "## 5. 값 해석 시 유의사항"
    lines << ""
    lines << "- 빈 값은 원본 데이터베이스의 `NULL` 또는 빈 문자열을 의미하며, 추출 과정에서 임의의 기본값을 넣지 않았다."
    lines << "- `death_status`, `heavy_lifting`, `work_relevance_eval`, `application_type`, `work_type`, `employment_type`은 정규화로 빈 문자열·공백을 `NULL`로 바꿨다. 이 컬럼들에서는 NULL만 결측이고 ‘추출하지 않음’과 ‘추출했으나 값 없음’은 구분되지 않는다. 그 밖의 추출 컬럼은 NULL과 빈 문자열을 함께 확인한다."
    lines << "- `application_type`은 `|`로 결합한 다중값(예: `유족급여|장의비`)이다. 토큰별로 세려면 `|`로 나누어 센다. `기타`는 8개 신청서 토큰에 해당하지 않는 값이며 원문은 `application_type_detail`에 있다."
    lines << "- `work_type`·`employment_type`의 `기타`는 분류하지 못한 값으로 원문 표기는 `*_detail`에 있다. 정규직과 상용직은 별개 범주이고, 비정규직 등은 `기타`다."
    lines << "- `result`, `disease_category`, `body_part` 등 enum 성격의 값은 현재 애플리케이션 내부 코드값이다. 표시용 한글명은 애플리케이션의 번역/enum 정의를 기준으로 변환한다."
    lines << "- `result`는 행정적 심의 결과의 분류값이지 질병 발생 확률, 업무 관련성의 연속 점수, 개인에 대한 예측값이 아니다."
    lines << "- `year`는 심의 연도이고 `decided_on`은 심의 결정일이다. `created_at`·`updated_at`은 데이터베이스 적재·수정 시각이므로 사건 발생일이나 심의일로 사용하지 않는다."
    lines << "- `id`는 데이터베이스 내부 식별자라서 재적재·마이그레이션 시 의미가 달라질 수 있다. 외부 분석 결과를 사례와 연결할 때는 `case_no`를 함께 보존한다."
    lines << "- `job_*`, `employment_type`, `work_*`, `main_reasoning` 등 추출 컬럼은 원문에서 후처리된 값이며, 원문 판정서의 모든 내용을 포함하거나 동일한 의미·정확도를 보장하지 않는다."
    lines << "- 텍스트 원문 안의 개인정보 비식별 표기(예: 일부 마스킹)는 원본 데이터에 저장된 표현이다. 이 CSV 생성 작업은 추가 마스킹을 하지 않는다."
    lines << "- `similarity`는 매칭 결과의 보조 점수이며 승인 가능성이나 법적 판단 확률을 의미하지 않는다."
    lines << ""
    lines << "## 6. 컬럼 그룹별 분석 가이드"
    lines << ""
    lines << "| 그룹 | 주요 컬럼 | 분석 용도 | 주의사항 |"
    lines << "|---|---|---|---|"
    lines << "| 식별·시점 | `id`, `case_no`, `year`, `decided_on`, `created_at`, `updated_at` | 사례 중복 제거, 기간 필터, 추출 이력 확인 | 내부 ID와 사건 시점을 혼동하지 않음 |"
    lines << "| 판정 결과 | `result`, `disease_category`, `body_part` | 결과 분포, 질병·부위별 교차표 | 인과관계나 승인 확률로 해석하지 않음 |"
    lines << "| 원문 근거 | `statement`, `claim_purpose`, `application_content`, `applicant_claim`, `medical_records`, `recognized_facts`, `related_laws`, `committee_decision` | 사례 맥락 확인, 질적 분석, 근거 인용 | 긴 텍스트·개인정보 가능성·표현 차이 검토 |"
    lines << "| 업무 추출값 | `job_name`, `job_description`, `employment_type`, `work_type`, `job_tenure_months`, `weekly_work_hours`, `daily_work_hours` | 직업·근로조건별 분포와 탐색 | `job_name`은 표기가 정규화되지 않았음. `employment_type`·`work_type`은 범주값이고 세부는 `*_detail` |"
    lines << "| 유해요인 추출값 | `burden_body_part`, `bad_posture`, `heavy_lifting`, `max_item_weight`, `daily_total_weight`, `other_harmful_factors`, `aggravating_factors` | 업무 부담 요인 탐색 | 텍스트/수치 혼합 가능, 결측이 곧 ‘없음’을 뜻하지 않음 |"
    lines << "| 판정 근거 추출값 | `work_relevance_eval`, `main_reasoning`, `death_status`, `application_type`, `application_type_detail` | 검색·요약·분류 보조 | 원문 판정의 법적 해석을 대체하지 않음. `application_type`은 `\\|` 결합 다중값 |"
    lines << ""
    lines << "## 7. 기본 품질 점검 예시"
    lines << ""
    lines << "분석 전에 다음 항목을 점검하는 것을 권장한다. 아래 SQL은 데이터베이스 테이블 기준이며, CSV를 사용할 때는 DuckDB의 `read_csv_auto()`로 각 파일을 읽어 적용할 수 있다."
    lines << ""
    lines << "```sql"
    lines << "-- 결과값 분포"
    lines << "SELECT result, COUNT(*) AS n FROM disease_cases GROUP BY result ORDER BY n DESC;"
    lines << ""
    lines << "-- 결정일 범위와 결정일 결측 확인"
    lines << "SELECT MIN(decided_on), MAX(decided_on), SUM(CASE WHEN decided_on IS NULL THEN 1 ELSE 0 END) AS missing_decided_on FROM disease_cases;"
    lines << ""
    lines << "-- 동일 사례 번호 중복 확인"
    lines << "SELECT case_no, COUNT(*) AS n FROM disease_cases GROUP BY case_no HAVING COUNT(*) > 1;"
    lines << ""
    lines << "-- 정규화 컬럼의 범주 분포 (application_type은 `|` 결합 값 그대로 집계)"
    lines << "SELECT employment_type, COUNT(*) AS n FROM disease_cases GROUP BY employment_type ORDER BY n DESC;"
    lines << "SELECT work_type, COUNT(*) AS n FROM disease_cases GROUP BY work_type ORDER BY n DESC;"
    lines << ""
    lines << "-- 특정 신청서 토큰을 포함한 사례 (파이프 경계 매칭)"
    lines << "SELECT COUNT(*) FROM disease_cases WHERE '|' || application_type || '|' LIKE '%|유족급여|%';"
    lines << ""
    lines << "-- NULL과 빈 문자열을 함께 고려한 추출값 결측 확인"
    lines << "SELECT SUM(CASE WHEN job_name IS NULL OR TRIM(job_name) = '' THEN 1 ELSE 0 END) AS missing_job_name, SUM(CASE WHEN main_reasoning IS NULL OR TRIM(main_reasoning) = '' THEN 1 ELSE 0 END) AS missing_main_reasoning FROM disease_cases;"
    lines << "```"
    lines << ""
    lines << "## 8. 해석·공유 제한"
    lines << ""
    lines << "- 이 데이터는 사례 기록의 관찰 분포를 설명하는 자료이며, 특정 개인의 산재 인정 여부나 미래 결과를 예측하는 근거로 사용해서는 안 된다."
    lines << "- 관찰된 결과 차이는 사례 구성, 신청·심의 시기, 기록 누락, 질병·직업 분류 방식 등의 영향을 받을 수 있다. 단순 교차표만으로 원인이나 인과를 주장하지 않는다."
    lines << "- 원문 컬럼을 포함한 CSV는 접근 권한을 제한하고, 외부 공유·모델 입력·보고서 인용 전 개인정보와 재식별 가능성을 검토한다."
    lines << "- 분석 결과를 재현하려면 이 스냅샷의 기준일, 파일명, 사용 컬럼, 결측 처리 규칙, 필터 조건을 함께 기록한다."
    lines << ""

    File.write(files[:dictionary], lines.join("\n") + "\n", mode: "wb")
  end

  def column_table(columns, model, descriptions)
    total = model.unscoped.count
    lines = [ "| 컬럼 | Rails 타입 | NULL 건수 | NULL 비율 | 설명 |", "|---|---|---:|---:|---|" ]
    columns.each do |column|
      type = model.columns_hash.fetch(column).type
      null_count = model.unscoped.where(column => nil).count
      null_rate = total.zero? ? "0.0%" : format("%.1f%%", null_count.fdiv(total) * 100)
      description = descriptions.fetch(column, "스키마에 정의된 `#{column}` 컬럼")
      lines << "| `#{column}` | `#{type}` | #{null_count.to_fs(:delimited)} | #{null_rate} | #{description} |"
    end
    lines
  end
end
