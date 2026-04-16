## 2. 데이터 모델 검토 및 제안

- 수정 의견: `DiseaseCase` 확장으로 결정

## 3. `DiseaseCase` 확장 마이그레이션

- 일부 컬럼만 추가합니다
  - 직종명, 담당_업무, 현_직종_총_종사기간, 1주_평균_근무시간, 1일_평균_근무시간, 부담_신체_부위, 주요_부적절한_자세
  - 중량물_취급_여부, 

----


# 업무상질병 판정서 직업·신체·사망 기반 검색 화면 구현 계획

> **목표**: `wip/extract_disease_cases_details_cerebras-ksco.csv` 및 `wip/ksco-level-4-details.csv`를 활용하여, 직업·업무·신체 부위·신청서 유형·사망 여부를 필터링하고 full-text 검색할 수 있는 새로운 메인 화면을 구현한다. 기존 전문 검색 화면은 `/search`로 이동하고, 새 화면이 루트(`/`)가 된다.

---

## 1. 개요 및 현재 상태

### 1.1 기존 시스템

| 항목 | 현재 상태 |
|------|----------|
| 루트 경로 (`/`) | `disease_cases#index` — 심의결과·질병분류·신체부위·판정일 필터 + 5개 본문 컬럼 FTS5 검색 |
| 모델 | `DiseaseCase` (18컬럼, `result`/`disease_category`/`body_part` enum) |
| FTS5 | `disease_cases_fts` (application_content, applicant_claim, medical_records, recognized_facts, committee_decision) |
| 검색 로직 | `DiseaseCases::Searchable` concern (한국어 조사 제거, BM25 정렬, substring fallback) |
| 데이터 임포트 | `lib/tasks/import_disease_cases.rake` (판정서 본문 + 목록 CSV → upsert) |

### 1.2 새로운 데이터

- **`wip/extract_disease_cases_details_cerebras-ksco.csv`**: 55,379건의 판정서에 대해 Cerebras/KSCO 모델로 추출한 직업 정보, 근무 조건, 신체 부위, 사망 여부, 신청서 종류, KSCO 매핑 등 21개 컬럼.
- **`wip/ksco-level-4-details.csv`**: 한국표준직업분류(KSCO) 4단계 코드 계층(코드, 세분류, 소분류, 중분류, 대분류, 직업예시, 직업제외).

### 1.3 요구사항 요약

1. **새 검색 화면이 메인**: `root` → 신규 액션. 기존 검색은 `/search`로 이동.
2. **핵심 필터**: 직업(직종명), 하는 일(담당 업무), 아픈 신체 부위(부담 신체 부위), 신청서 유형, 사망 여부.
3. **Full-text 검색**: 직업·업무·판단 근거 등 새로 추출된 텍스트 컬럼 대상.
4. **KSCO 연동**: KSCO 코드 모델을 별도로 만들고, 판정서와 N:M 연결(유사도 포함).
5. **모델 결정**: 기존 `DiseaseCase`를 확장할지, 새 클래스를 만들지 검토 및 제안.

---

## 2. 데이터 모델 검토 및 제안

### 2.1 검토 대상

| 접근법 | 설명 | 장점 | 단점 |
|--------|------|------|------|
| **A. `DiseaseCase` 확장** ⭐ | 기존 테이블에 추출 컬럼 마이그레이션 추가 | 단일 테이블, 기존 검색 로직 재사용, 관계 단순, SQLite 트랜잭션 간단 | FTS5 가상 테이블 재생성 필요 |
| **B. `DiseaseCaseDetail` 신규** | `disease_cases` 1:1 연결 테이블 | 기존 스키마 불변, 추출 데이터 분리 관리 가능 | 조인 복잡도 증가, N+1 리스크, 동일 `case_no` 관리 오버헤드 |
| **C. `ExtractedDiseaseCase` 신규** | 기존 데이터와 완전 분리한 복제 테이블 | 기존 시스템 영향 제로 | 데이터 중복, `case_no` 동기화 부담, 유지보수 비용 증가 |

### 2.2 제안: `DiseaseCase` 확장 (접근법 A)

**근거**:
- 추출 데이터는 동일 판정서(`case_no`)에 대한 **속성 확장**이지 별개 엔터티가 아니다.
- SQLite 단일 파일 구조상 1:1 조인은 성능/복잡도상 불리하다.
- 기존 `DiseaseCase.search`, `pagy`, 로깅, PII 마스킹(`as_safe_json`) 인프라를 그대로 재사용할 수 있다.
- FTS5 가상 테이블 재생성은 마이그레이션 한 번으로 해결 가능하며, 데이터 양(55K)에도 재인덱싱은 수 초 내외다.

**예외 처리**:
- `최종_산재_인정_여부`는 기존 `result` 컬럼과 의미 중복이므로 **별도 컬럼 없이** 기존 `result` enum을 그대로 사용. 추출 데이터로 기존 값을 검증/보정하는 용도로만 활용.

---

## 3. `DiseaseCase` 확장 마이그레이션

### 3.1 추가 컬럼 (`db/migrate/xxx_add_extracted_columns_to_disease_cases.rb`)

| DB 컬럼 (snake_case) | 원본 CSV 컬럼 | 타입 | 인덱스 | 검색/필터 용도 |
|----------------------|--------------|------|--------|---------------|
| `job_name` | 직종명 | `string` | ✅ | 직업 필터, FTS5 |
| `job_description` | 담당_업무 | `text` | — | 하는일 필터, FTS5 |
| `employment_type` | 고용_형태 | `string` | ✅ | 고용 형태 필터 (드롭다운) |
| `work_type` | 근무_형태 | `string` | ✅ | 근무 형태 필터 |
| `job_tenure` | 현_직종_총_종사기간 | `string` | — | 기간 표시 (원본 단위 보존) |
| `weekly_work_hours` | 1주_평균_근무시간 | `decimal` | — | 통계/표시 |
| `daily_work_hours` | 1일_평균_근무시간 | `decimal` | — | 통계/표시 |
| `burden_body_part` | 부담_신체_부위 | `string` | ✅ | 아픈 신체 부위 필터 |
| `bad_posture` | 주요_부적절한_자세 | `string` | — | 부적절 자세 표시 |
| `heavy_lifting` | 중량물_취급_여부 | `string` (Y/N) | ✅ | 중량물 취급 필터 |
| `max_item_weight` | 취급_물품_최대_무게 | `string` | — | 무게 표시 |
| `daily_total_weight` | 1일_취급_총_누적_중량 | `string` | — | 중량 표시 |
| `other_harmful_factors` | 기타_유해요인_노출 | `text` | — | 유해요인 표시, FTS5 후보 |
| `work_relevance_eval` | 업무관련성_평가 | `string` | ✅ | 업무관련성 필터 (낮음/보통/높음/매우_높음) |
| `aggravating_factors` | 업묵부담_가중요인_노출 | `text` | — | 가중요인 표시, FTS5 후보 |
| `main_reasoning` | 판단_주요_근거 | `text` | — | 판단 근거 FTS5 |
| `death_status` | 사망_여부 | `string` (Y/N) | ✅ | **사망 여부 필터** |
| `application_type` | 신청서_종류 | `string` | ✅ | **신청서 유형 필터** |

> **참고**: `boolean` 대신 `string`로 Y/N을 저장하면 원본 그대로 유지되며, 나중에 `enum`으로 전환하기도 쉽다. SQLite boolean은 사실상 integer라 차이 미미.

### 3.2 Enum 후보 (데이터 분석 후 결정)

아래 컬럼은 cardinality가 낮으면 enum으로 전환하여 필터 UI 일관성을 높인다.

- `employment_type`: `["상용직", "일용직", ""]` (빈 값은 미상)
- `work_type`: `["고정 주간근무", "교대근무", "주간고정근무", ...]` (데이터 profiling 후 확정)
- `work_relevance_eval`: `["낮음", "보통", "높음", "매우_높음"]`
- `death_status`: `["Y", "N"]` → boolean enum 처리 가능
- `application_type`: `["요양급여", "유족급여 및 장의비", "요양급여신청서", "유족급여 및 장의비청구서", ...]` (정규화 필요)

---

## 4. KSCO 표준직업분류 모델

- 수정의견
  - code 에 대한 name은 level4_name 입니다. 컬럼 level4_name 을 name 으로 바꿉니다
  - level1_name, level2_name, level3_name 를 major, submajor, minor 로 바꿉니다


### 4.1 `KscoCode` 모델 (`db/migrate/xxx_create_ksco_codes.rb`)

| 컬럼 | 타입 | 제약 | 설명 |
|------|------|------|------|
| `code` | `string` | PK | 4자리 코드 (예: 9414) |
| `level4_name` | `string` | — | 세분류 (예: 재활용품 및 쓰레기 수거원) |
| `level3_name` | `string` | — | 소분류 (예: 재활용 처리 및 소각로 조작원) |
| `level2_name` | `string` | — | 중분류 |
| `level1_name` | `string` | — | 대분류 (예: 관리자) |
| `job_examples` | `text` | — | 직업예시 (파이프 구분) |
| `exclusions` | `text` | — | 직업제외 |

**모델 설정**:
```ruby
class KscoCode < ApplicationRecord
  self.primary_key = "code"

  has_many :disease_case_ksco_codes, primary_key: "code", foreign_key: "ksco_code_id"
  has_many :disease_cases, through: :disease_case_ksco_codes
end
```

**마이그레이션**:
```ruby
create_table :ksco_codes, id: false do |t|
  t.string :code, primary_key: true
  t.string :level4_name
  t.string :level3_name
  t.string :level2_name
  t.string :level1_name
  t.text   :job_examples
  t.text   :exclusions
end
```

### 4.2 `DiseaseCaseKscoCode` 조인 모델

| 컬럼 | 타입 | 설명 |
|------|------|------|
| `disease_case_id` | `bigint` | FK |
| `ksco_code_id` | `string` | FK (KscoCode.code) |
| `similarity` | `float` | 유사도 점수 (0~1, 표시/정렬용) |

- 복합 인덱스: `[disease_case_id, ksco_code_id]` (unique), `[ksco_code_id]` (검색용)

**모델 설정**:
```ruby
class DiseaseCaseKscoCode < ApplicationRecord
  belongs_to :disease_case
  belongs_to :ksco_code, primary_key: "code", foreign_key: "ksco_code_id"
end
```

`DiseaseCase`에 추가:
```ruby
has_many :disease_case_ksco_codes
has_many :ksco_codes, through: :disease_case_ksco_codes
```

### 4.3 직업 필터 검색 시나리오

1. **직종명 텍스트 검색**: `job_name` 컬럼 LIKE/FTS5 검색.
2. **KSCO 코드 필터**: 사용자가 KSCO 분류(대분류→중분류→소분류→세분류)를 선택하면, 해당 코드를 가진 `DiseaseCase`를 `JOIN`으로 검색.
3. **자동완성**: `KscoCode.level4_name`을 대상으로 prefix 검색하여 드롭다운 제안.

---

## 5. 검색 아키텍처

### 5.1 라우팅 변경 (`config/routes.rb`)

```ruby
Rails.application.routes.draw do
  # NEW: 메인 화면 (직업·신체·사망 기반 검색)
  root "disease_cases#main"

  # OLD: 기존 전문 검색 화면을 /search 로 이동
  get "/search", to: "disease_cases#index", as: :search

  # 판정서 상세는 그대로 유지
  resources :disease_cases, param: :case_no, only: [:show]

  get "/about", to: "pages#about", as: :about
  get "up" => "rails/health#show", :as => :rails_health_check
end
```

> `disease_cases#index`를 그대로 두되 경로만 `/search`로 바꾼다. 기존 검색 form의 `url:`도 `root_path` → `search_path`로 수정 필요.

### 5.2 컨트롤러 구조

**`DiseaseCasesController`**에 `main` 액션 추가:

```ruby
class DiseaseCasesController < ApplicationController
  MAX_SEARCH_RESULTS = 500

  # 기존 /search (이전에는 root)
  def index
    perform_search(legacy: true)
  end

  # NEW: / (메인 화면)
  def main
    perform_search(legacy: false)
  end

  def show
    @disease_case = DiseaseCase.find_by(case_no: params[:case_no])
  end

  private

  def perform_search(legacy:)
    @scope, @fallback = legacy ? DiseaseCase.search(search_params) : DiseaseCase.main_search(main_search_params)
    @pagy, @cases = paginate(@scope)
    @metadata = build_metadata
    log_search_event(legacy: legacy)
  end

  def paginate(scope)
    pagy(scope, items: 12, max_items: MAX_SEARCH_RESULTS)
  end

  # ... (build_metadata, log_search_event 등 기존 유지)

  def main_search_params
    params.permit(
      :q, :job_name, :duty_description, :burden_body_part,
      :death_status, :application_type, :employment_type, :work_type,
      :work_relevance_eval, :sort, :commit, :search,
      ksco_code: []
    )
  end
end
```

### 5.3 검색 Concern 분리

기존 `DiseaseCases::Searchable`는 `/search` (legacy)용으로 그대로 유지.
새 concern `DiseaseCases::MainSearchable`를 생성하여 `/` (main)용 로직을 분리.
> **리팩토링 주의**: `normalize_query`, `build_fts_query`, `sanitize_sql_like` 기반 substring fallback 등은 두 concern에서 **동일한 로직**이다. 구현 시 `DiseaseCases::Searchable`의 private 메서드를 protected로 변경하거나, 별도 `DiseaseCases::QueryBuilder` 모듈로 추출하여 양쪽 concern에서 `include`/`delegate`로 재사용한다. 코드 중복을 피해야 향후 한국어 파티클 처리, SQL Injection 방지 등의 수정이 한 곳에서만 이루어진다.

```ruby
# app/models/concerns/disease_cases/main_searchable.rb
module DiseaseCases
  module MainSearchable
    extend ActiveSupport::Concern

    MAIN_SEARCHABLE_COLUMNS = %w[
      job_name
      duty_description
      main_reasoning
      other_harmful_factors
      aggravating_factors
    ].freeze

    class_methods do
      def main_search(params = {})
        raw_query = params[:q].to_s.strip
        tokens = normalize_query(raw_query).split(" ").first(5)

        # 1. Full-text scope (새 FTS5 가상 테이블 사용)
        if raw_query.present?
          fts_scope = main_fulltext(build_main_fts_query(raw_query))
          if fts_scope.empty?
            scope = substring_job_fallback(tokens)
            fallback = true
          else
            scope = fts_scope
            fallback = false
          end
        else
          scope = all
          fallback = false
        end

        # 2. Structured filters
        scope = apply_main_filters(scope, params)

        # 3. Sort
        scope = apply_main_sort(scope, raw_query, fallback, params[:sort])

        [scope, fallback]
      end

      private

      def apply_main_filters(scope, params)
        # 직업/하는일: 부분 일치 (LIKE) — exact match는 표현 통일성이 없는 추출 데이터에서 0건 위험
        if params[:job_name].present?
          safe = sanitize_sql_like(params[:job_name])
          scope = scope.where("job_name LIKE ?", "%#{safe}%")
        end

        if params[:duty_description].present?
          safe = sanitize_sql_like(params[:duty_description])
          scope = scope.where("duty_description LIKE ?", "%#{safe}%")
        end

        scope = scope.where(burden_body_part: params[:burden_body_part]) if params[:burden_body_part].present?
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

      def build_main_fts_query(raw, columns = MAIN_SEARCHABLE_COLUMNS)
        # 기존 normalize + 토큰화 로직 재사용
        # ... (DiseaseCases::Searchable 패턴 유지)
      end

      def substring_job_fallback(tokens)
        safe_tokens = tokens.first(2).map { |token| sanitize_sql_like(token) }
        conditions = safe_tokens.map { "job_name LIKE ? OR duty_description LIKE ?" }.join(" AND ")
        binds = safe_tokens.flat_map { |token| ["%#{token}%", "%#{token}%"] }
        where(conditions, *binds)
      end
    end
  end
end
```

### 5.4 새 FTS5 가상 테이블

기존 `disease_cases_fts`는 **그대로 유지**하여 기존 `/search` 검색에 영향을 주지 않는다.
새 가상 테이블 `disease_cases_extracted_fts`를 생성하여 메인 검색 전용으로 사용:

```ruby
# db/migrate/xxx_create_disease_cases_extracted_fts.rb
class CreateDiseaseCasesExtractedFts < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      CREATE VIRTUAL TABLE disease_cases_extracted_fts
      USING fts5(
        job_name,
        duty_description,
        main_reasoning,
        other_harmful_factors,
        aggravating_factors,
        content='disease_cases',
        content_rowid='id',
        tokenize='unicode61'
      );
    SQL

    # INSERT/UPDATE/DELETE triggers (기존 패턴과 동일)
    execute <<~SQL
      CREATE TRIGGER disease_cases_extracted_fts_insert
      AFTER INSERT ON disease_cases BEGIN
        INSERT INTO disease_cases_extracted_fts(
          rowid, job_name, duty_description, main_reasoning,
          other_harmful_factors, aggravating_factors
        ) VALUES (
          new.id, new.job_name, new.duty_description, new.main_reasoning,
          new.other_harmful_factors, new.aggravating_factors
        );
      END;
    SQL

    # ... UPDATE/DELETE triggers 동일 패턴
  end
end
```

---

## 6. 필터 명세 (메인 검색 화면)

### 6.1 필터 UI 구성

| 필터 | 입력 방식 | 대상 컬럼/관계 | 비고 |
|------|----------|---------------|------|
| **직업 (직종명)** | 텍스트 입력 + KSCO 자동완성 | `job_name` (FTS5) / `ksco_codes` (JOIN) | KSCO 선택 시 해당 코드 연결된 판정서 검색 |
| **하는일 (담당 업무)** | 텍스트 입력 | `duty_description` (FTS5) | 한국어 조사 제거 적용 |
| **아픈 신체 부위** | 드롭다운 / 멀티셀렉트 | `burden_body_part` | 데이터 profiling 후 distinct 값으로 enum 또는 string 필터 |
| **신청서 유형** | 드롭다운 | `application_type` | 정규화된 enum 값 |
| **사망 여부** | 스위치 / 체크박스 | `death_status` | Y/N |
| **Full-text 검색** | 텍스트 입력 | `disease_cases_extracted_fts` (5개 컬럼) | 기존 FTS5 패턴 재사용 |
| **심의결과** | 드롭다운 (기존 유지) | `result` | 메인 화면에서도 노출 가능 (선택 사항) |
| **정렬** | 라디오 버튼 | relevance / recent | BM25 (FTS5) 또는 `year DESC` |

### 6.2 KSCO 필터 상호작용

1. 사용자가 "버스 운전원" 입력.
2. 자동완성이 `KscoCode.where("level4_name LIKE ?", "버스 운전원%")`로 제안.
3. 사용자가 KSCO 코드 `8722` 선택.
4. 검색 쿼리: `DiseaseCase.joins(:ksco_codes).where(ksco_codes: { code: "8722" })`.
5. 선택된 KSCO 코드는 파라미터 `ksco_code[]`로 전달 (멀티 선택 가능).

---

## 7. 데이터 임포트 전략

### 7.1 KSCO 코드 임포트

```bash
rails import:ksco_codes[wip/ksco-level-4-details.csv]
```

```ruby
# lib/tasks/import_ksco_codes.rake
namespace :import do
  task :ksco_codes, [:path] => :environment do |_, args|
    require "csv"
    path = args[:path] or abort "CSV 경로를 지정하세요."

    imported = 0
    CSV.foreach(path, headers: true, encoding: "UTF-8") do |row|
      KscoCode.find_or_initialize_by(code: row["코드"].to_s.strip).update!(
        level4_name: row["세분류"].to_s.strip,
        level3_name: row["소분류"].to_s.strip,
        level2_name: row["중분류"].to_s.strip,
        level1_name: row["대분류"].to_s.strip,
        job_examples: row["직업예시"].to_s.strip,
        exclusions: row["직업제외"].to_s.strip
      )
      imported += 1
    end
    puts "KSCO 임포트 완료: #{imported}건"
  end
end
```

### 7.2 추출 판정서 상세 임포트

```bash
rails import:extracted_disease_cases[wip/extract_disease_cases_details_cerebras-ksco.csv]
```

```ruby
# lib/tasks/import_extracted_disease_cases.rake
namespace :import do
  task :extracted_disease_cases, [:path] => :environment do |_, args|
    require "csv"
    require "json"
    path = args[:path] or abort "CSV 경로를 지정하세요."

    rows = CSV.read(path, headers: true, encoding: "UTF-8")
    puts "추출 데이터: #{rows.size}건"

    imported = 0
    errors = 0

    rows.each do |row|
      case_no = row["case_no"].to_s.strip
      record = DiseaseCase.find_by(case_no: case_no)
      unless record
        warn "판정서 없음: #{case_no}"
        errors += 1
        next
      end

      # 1. 기존 DiseaseCase 속성 업데이트
      record.update!(
        job_name: row["직종명"].to_s.strip,
        duty_description: row["담당_업무"].to_s.strip,
        employment_type: row["고용_형태"].to_s.strip,
        work_type: row["근무_형태"].to_s.strip,
        job_tenure: row["현_직종_총_종사기간"].to_s.strip,
        weekly_work_hours: row["1주_평균_근무시간"].to_s.strip.presence&.to_d,
        daily_work_hours: row["1일_평균_근무시간"].to_s.strip.presence&.to_d,
        burden_body_part: row["부담_신체_부위"].to_s.strip,
        bad_posture: row["주요_부적절한_자세"].to_s.strip,
        heavy_lifting: row["중량물_취급_여부"].to_s.strip,
        max_item_weight: row["취급_물품_최대_무게"].to_s.strip,
        daily_total_weight: row["1일_취급_총_누적_중량"].to_s.strip,
        other_harmful_factors: row["기타_유해요인_노출"].to_s.strip,
        work_relevance_eval: row["업무관련성_평가"].to_s.strip,
        aggravating_factors: row["업묵부담_가중요인_노출"].to_s.strip,
        main_reasoning: row["판단_주요_근거"].to_s.strip,
        death_status: row["사망_여부"].to_s.strip,
        application_type: row["신청서_종류"].to_s.strip
      )

      # 2. KSCO 매핑 저장 (JSON 파싱)
      ksco_json = row["ksco_codes_json"].to_s.strip
      if ksco_json.present?
        JSON.parse(ksco_json).each_with_index do |item, idx|
          code = item["ksco_code"].to_s.strip
          next if code.blank?

          ksco = KscoCode.find_by(code: code)
          unless ksco
            warn "KSCO 코드 없음: #{code} (case_no=#{case_no})"
            next
          end

          record.disease_case_ksco_codes.find_or_initialize_by(ksco_code_id: code).update!(
            similarity: item["similarity"].to_f
          )
        end
      end

      imported += 1
    rescue => e
      errors += 1
      warn "오류 (case_no=#{case_no}): #{e.message}"
    end

    puts "추출 데이터 임포트 완료: #{imported}건 / 오류: #{errors}건"

    # FTS5 재생성
    ActiveRecord::Base.connection.execute(
      "INSERT INTO disease_cases_extracted_fts(disease_cases_extracted_fts) VALUES('rebuild')"
    )
    puts "Extracted FTS rebuild 완료"
  end
end
```

> **주의**: `ksco_codes_json`에 포함된 코드가 `KscoCode` 테이블에 없는 경우가 있을 수 있다 (CSV가 완전하지 않을 수 있음). `find_or_initialize_by` + `warn`로 처리.

---

## 8. UI/UX 개요

### 8.1 메인 화면 (`app/views/disease_cases/main.html.erb`)

- **Hero 검색창**: 큰 텍스트 입력 (Full-text) + 검색 버튼.
- **필터 패널** (화면 좌측 또는 상단 아코디언):
  - 직업: 텍스트 입력 + KSCO 자동완성 드롭다운.
  - 하는일: 텍스트 입력.
  - 아픈 신체 부위: 체크박스 그룹 (기존 `body_part` UI와 유사).
  - 신청서 유형: 셀렉트 박스.
  - 사망 여부: 토글 스위치 (Y/N).
  - KSCO 계층: 대분류 → 중분류 → 소분류 → 세분류 연동 셀렉트 (선택 사항, 2차 구현).
- **결과 목록**: 카드 또는 테이블 형태. 각 항목에 직종명, 담당업무 요약, 신청서 유형, 사망 여부 배지, KSCO 코드 태그 표시.
- **페이지네이션**: `pagy` 재사용.

### 8.2 기존 검색 화면 이동 (`app/views/disease_cases/index.html.erb`)

- `form_with url: search_path`로 변경.
- 그 외 UI는 기존과 동일하게 유지.

### 8.3 레이아웃 네비게이션 수정 (`app/views/layouts/application.html.erb`)

`root_path`가 새 메인 화면(`disease_cases#main`)을 가리키게 되므로, 상단 내비게이션의 "검색" 링크는 `search_path`로 명시적으로 변경해야 한다. "업무상 질병 판정서" 브랜드 링크와 "검색" 링크가 동일한 URL을 가리키는 상황을 방지하고, 사용자가 기존 전문 검색(`/search`)에 접근할 수 있도록 유지한다.

```erb
<%= link_to t("nav.search"), search_path %>
```

---

## 9. 구현 단계

### Phase 1: 모델 및 마이그레이션 (1~2일)

1. [ ] `KscoCode` 모델 + 마이그레이션 생성
2. [ ] `DiseaseCaseKscoCode` 조인 모델 + 마이그레이션 생성
3. [ ] `DiseaseCase` 확장 마이그레이션 (18개 신규 컬럼 + 인덱스)
4. [ ] `disease_cases_extracted_fts` FTS5 가상 테이블 + 트리거 마이그레이션
5. [ ] `DiseaseCase` 모델에 `has_many :disease_case_ksco_codes` 등 관계 추가
6. [ ] `DiseaseCases::MainSearchable` concern 신규 생성 (기존 `Searchable`는 그대로 유지)

### Phase 2: 데이터 임포트 (1일)

7. [ ] `import:ksco_codes` rake task 작성 및 실행
8. [ ] `import:extracted_disease_cases` rake task 작성 및 실행
9. [ ] 데이터 검증: `DiseaseCase.where(job_name: nil).count` 등으로 누락 확인

### Phase 3: 라우팅, 컨트롤러 및 MCP Tool (0.5~1일)

10. [ ] `routes.rb` 변경: `root` → `disease_cases#main`, `/search` → `disease_cases#index`
11. [ ] `DiseaseCasesController#main` 액션 추가
12. [ ] `main_search_params` strong parameters 정의
13. [ ] 기존 `index.html.erb`의 `form_with url:`을 `search_path`로 수정
14. [ ] `app/mcp/tools/search_disease_cases_tool.rb` 업데이트: `job_name`, `duty_description`, `ksco_code`, `death_status` 파라미터 노출, ad-hoc 키워드 매칭을 새 구조화 필터로 대체/보완

### Phase 4: UI 개발 (2~3일)

15. [ ] `main.html.erb` 신규 작성 (필터 패널 + 결과 목록)
16. [ ] KSCO 자동완성 Stimulus 컨트롤러 (`ksco_autocomplete_controller.js`)
17. [ ] 필터별 UI 컴포넌트 (체크박스, 셀렉트, 토글)
18. [ ] 결과 카드/테이블 행 디자인 (직종명, KSCO 태그, 사망 배지)
19. [ ] Oat CSS 클래스 적용 및 반응형 처리

### Phase 5: 테스트 및 검증 (1일)

20. [ ] `main_search` concern 유닛 테스트 (필터 조합, FTS5 fallback)
21. [ ] 통합 테스트: `/` 접속 → 필터 적용 → 결과 확인
22. [ ] 기존 `/search` 경로 회귀 테스트 (기능 퇴행 확인)
23. [ ] MCP Tool 테스트: LLM 클라이언트 시나리오로 `job_name`/`death_status` 필터 정상 동작 확인
24. [ ] LSP diagnostics / `rubocop` 통과

---

## 10. 리스크 및 대응

| 리스크 | 영향 | 대응 |
|--------|------|------|
| `burden_body_part` 데이터 누락 다수 | 필터 UI가 비어 보임 | 데이터 profiling 먼저 실행. 누락 시 기존 `body_part`를 fallback 표시하거나, enum 대신 자유 텍스트 필터 + autocomplete로 전환 |
| `ksco_codes_json` 내 코드가 `KscoCode` 테이블에 없음 | JOIN 시 누락 | rake task에서 `warn` 출력 후 무시. 추후 KSCO CSV 보완 |
| FTS5 가상 테이블 2개 동시 유지 | 마이그레이션 복잡도 | 기존/신규 트리거를 별도 마이그레이션 파일로 분리. `db:migrate` 순서 명확히 |
| 기존 검색 경로 변경 | 외부 링크/북마크 깨짐 | README, MCP 문서, `workercare.plan.md` 경로 동시 업데이트. `/`는 그대로 유효하므로 영향 최소 |

---

## 11. 결론

- **모델**: 기존 `DiseaseCase`를 확장한다. 1:1 분리는 불필요한 복잡도만 추가한다.
- **KSCO**: 별도 `KscoCode` + `DiseaseCaseKscoCode` 조인 테이블로 관리.
- **검색**: 기존 `/search` (legacy)는 `DiseaseCases::Searchable` + `disease_cases_fts` 그대로 유지. 새 메인 화면은 `DiseaseCases::MainSearchable` + `disease_cases_extracted_fts`로 분리 구현.
- **데이터**: `import:ksco_codes` → `import:extracted_disease_cases` 순서로 실행.
- **UI**: 직업/KSCO 중심의 필터 패널 + Full-text Hero 검색창.
- **MCP**: `app/mcp/tools/search_disease_cases_tool.rb`를 함께 업데이트하여, LLM 클라이언트가 새 `job_name`/`duty_description`/`ksco_codes`/`death_status` 컬럼을 필터로 사용할 수 있도록 한다. 기존의 `work_match?`/`symptom_match?` 같은 ad-hoc 키워드 매칭은 새 구조화 데이터로 대체하거나 보완한다.

**다음 액션**: Phase 1 마이그레이션 승인 후 `rails db:migrate` 실행.
