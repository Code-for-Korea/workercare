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
| `job_description` | 담당_업무 | `text` | — | 하는일 필터, FTS5. **주의**: 아래 5.3/5.4절 코드 예시에서도 반드시 `job_description`으로 통일해서 참조한다 (`duty_description`이라는 이름은 이 문서 어디에도 쓰지 않는다 — 실제 컬럼이 존재하지 않아 strong params가 값을 버리고 FTS/임포트 코드가 없는 컬럼을 참조해 런타임 에러가 난다) |
| `employment_type` | 고용_형태 | `string` | ✅ | 고용 형태 필터 (드롭다운) |
| `work_type` | 근무_형태 | `string` | ✅ | 근무 형태 필터 |
| `job_tenure_months` | 현_직종_총_종사기간 | `integer` | — | `wip/cerebras_prompts.rb`의 추출 스키마상 숫자(개월)이므로 `string`이 아닌 `integer`로 저장 |
| `weekly_work_hours` | 1주_평균_근무시간 | `decimal` | — | 통계/표시 |
| `daily_work_hours` | 1일_평균_근무시간 | `decimal` | — | 통계/표시 |
| `burden_body_part` | 부담_신체_부위 | `text` | — | **다중값**: 추출 스키마상 배열이며 실제 CSV에도 파이프(`\|`)로 구분되어 저장됨(예: `"목\|상체\|하체"`). 파이프 구분 문자열 그대로 저장하고, 필터는 exact match(`where(burden_body_part: ...)`)도, 단순 `LIKE '%값%'`도 아닌 **파이프 경계를 인식하는 LIKE**로 처리한다 (5.3절 참고) — 단순 substring 매칭은 CSV에 이미 공존하는 "목"/"뒷목"/"손목"/"발목" 때문에 "목" 선택 시 "손목"만 있는 레코드까지 잘못 걸린다. 부분 문자열 매칭이라 인덱스 효과가 없어 인덱스는 만들지 않는다 |
| `bad_posture` | 주요_부적절한_자세 | `text` | — | 다중값(파이프 구분), 표시용 |
| `heavy_lifting` | 중량물_취급_여부 | `string` (Y/N) | ✅ | 중량물 취급 필터 |
| `max_item_weight` | 취급_물품_최대_무게 | `decimal` | — | 추출 스키마상 숫자(kg) |
| `daily_total_weight` | 1일_취급_총_누적_중량 | `decimal` | — | 추출 스키마상 숫자(kg) |
| `other_harmful_factors` | 기타_유해요인_노출 | `text` | — | 다중값(파이프 구분), 표시, FTS5 후보 |
| `work_relevance_eval` | 업무관련성_평가 | `string` | ✅ | 업무관련성 필터. **주의**: 추출 스키마(`wip/cerebras_prompts.rb`)상 허용값은 6개 — `매우_높음/높음/보통/낮음/매우_낮음/미흡`. 4개만 나열하면 `매우_낮음`/`미흡` 데이터가 필터로 찾을 수 없게 된다 |
| `aggravating_factors` | 업묵부담_가중요인_노출 | `text` | — | 다중값(파이프 구분, 원본 컬럼명의 오타 "업묵부담"은 그대로 둠), FTS5 후보 |
| `main_reasoning` | 판단_주요_근거 | `text` | — | 다중값(파이프 구분), FTS5 |
| `death_status` | 사망_여부 | `string` (Y/N) | ✅ | **사망 여부 필터** |
| `application_type` | 신청서_종류 | `string` | ✅ | **신청서 유형 필터** |

> **참고**: `boolean` 대신 `string`로 Y/N을 저장하면 원본 그대로 유지되며, 나중에 `enum`으로 전환하기도 쉽다. SQLite boolean은 사실상 integer라 차이 미미.
> **숫자 필드 주의**: `job_tenure_months`/`max_item_weight`/`daily_total_weight`를 문자열로 저장하면 정렬·범위 필터·유효성 검증에서 숫자 semantics를 잃는다. 반드시 `integer`/`decimal`로 저장한다.

### 3.2 Enum 후보 (데이터 분석 후 결정)

아래 컬럼은 cardinality가 낮으면 enum으로 전환하여 필터 UI 일관성을 높인다.

- `employment_type`: `["상용직", "일용직", ""]` (빈 값은 미상)
- `work_type`: `["고정 주간근무", "교대근무", "주간고정근무", ...]` (데이터 profiling 후 확정 — 실제 값은 `"주간고정근무 (일부 야간작업)"`처럼 괄호 부가 설명이 붙어 자유 텍스트에 가까움)
- `work_relevance_eval`: `["매우_높음", "높음", "보통", "낮음", "매우_낮음", "미흡"]` (`wip/cerebras_prompts.rb`의 추출 스키마 기준 6개 전부 — 4개만 쓰면 `매우_낮음`/`미흡` 데이터를 필터로 찾을 수 없다)
- `death_status`: `["Y", "N"]` → boolean enum 처리 가능
- `application_type`: `["요양급여", "유족급여 및 장의비", "요양급여신청서", "유족급여 및 장의비청구서", ...]` (정규화 필요)
- `burden_body_part`/`bad_posture`: 파이프 구분 다중값이므로 단일 컬럼 enum으로 만들지 않는다.
  > **해결됨 (실 데이터 profiling 결과)**: `burden_body_part`를 실제 CSV(`wip/extract_disease_cases_details_cerebras-ksco.csv`)에서 파이프로 split해 집계한 결과, distinct 원자값이 **1,174개**였다(원본 combined 문자열 기준 7,334개). 빈도 상위 10개가 전체 (행,토큰) 발생의 67.6%, 상위 20개 83.0%, 상위 30개 88.5%를 차지하는 롱테일 분포(우측/좌측/양측 접두어, "어깨"/"견관절" 같은 동의어가 원인)라 전부 체크박스로 노출할 수 없었다. 최종적으로 **상위 12개만 체크박스**(빈도순으로 골라 표시는 가나다순)로 노출하고, 나머지는 새 텍스트 입력 `burden_body_part_text`에 네이티브 HTML `<datalist>`(전체 distinct 토큰을 `<option>`으로 나열)로 자동완성해 찾도록 했다. 자유 텍스트 값도 체크박스와 동일한 파이프 경계 인식 LIKE 매칭을 그대로 탄다(5.3절 `apply_main_filters` 참고). KSCO 계층형 자동완성처럼 별도 Stimulus 컴포넌트나 서버 엔드포인트를 새로 만들지 않고 브라우저 네이티브 기능만으로 구현 범위를 좁혔다.

---

## 4. KSCO 표준직업분류 모델

- 수정의견
  - code 에 대한 name은 level4_name 입니다. 컬럼 level4_name 을 name 으로 바꿉니다
  - level1_name, level2_name, level3_name 를 major, submajor, minor 로 바꿉니다


### 4.1 `KscoCode` 모델 (`db/migrate/xxx_create_ksco_codes.rb`)

> **컬럼명 확정**: `code`에 대한 이름 컬럼은 `level4_name`이 아니라 `name`으로, `level1_name`/`level2_name`/`level3_name`은 각각 `major`/`submajor`/`minor`로 만든다 (아래 표·마이그레이션·모델·자동완성 예시 전부 이 이름을 사용).

| 컬럼 | 타입 | 제약 | 설명 |
|------|------|------|------|
| `code` | `string` | PK | 4자리 코드 (예: 9414) |
| `name` | `string` | — | 세분류 (was `level4_name`, 예: 재활용품 및 쓰레기 수거원) |
| `minor` | `string` | — | 소분류 (was `level3_name`, 예: 재활용 처리 및 소각로 조작원) |
| `submajor` | `string` | — | 중분류 (was `level2_name`) |
| `major` | `string` | — | 대분류 (was `level1_name`, 예: 관리자) |
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
  t.string :name       # 세분류 (was level4_name)
  t.string :minor      # 소분류 (was level3_name)
  t.string :submajor   # 중분류 (was level2_name)
  t.string :major      # 대분류 (was level1_name)
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
has_many :disease_case_ksco_codes, dependent: :delete_all
has_many :ksco_codes, through: :disease_case_ksco_codes
```

> **해결됨 (코드 리뷰에서 발견된 버그)**: 처음에는 `dependent` 옵션 없이 구현했는데, `disease_case_ksco_codes.disease_case_id`에 DB 레벨 FK가 걸려있어(위 마이그레이션의 `foreign_key: true`) KSCO 매핑이 붙은 판정서를 `destroy`하면 `ActiveRecord::InvalidForeignKey`가 발생했다(재현·확인됨). `DiseaseCaseKscoCode`에는 콜백이 없으므로 개별 row를 인스턴스화하지 않는 `dependent: :delete_all`을 선택했다.

### 4.3 직업 필터 검색 시나리오

1. **직종명 텍스트 검색**: `job_name` 컬럼 LIKE/FTS5 검색.
2. **KSCO 코드 필터**: 사용자가 KSCO 분류(대분류`major`→중분류`submajor`→소분류`minor`→세분류`name`)를 선택하면, 해당 코드를 가진 `DiseaseCase`를 `JOIN`으로 검색.
3. **자동완성**: `KscoCode.name`을 대상으로 prefix 검색하여 드롭다운 제안.

---

## 5. 검색 아키텍처

### 5.1 라우팅 변경 (`config/routes.rb`)

```ruby
Rails.application.routes.draw do
  # 메인 화면 (직업·신체·사망 기반 검색)
  root "disease_cases#index"

  # 기존 전문 검색 화면을 /search 로 이동
  get "/search", to: "disease_cases#search", as: :search

  # 판정서 상세는 그대로 유지
  resources :disease_cases, param: :case_no, only: [:show]

  get "/about", to: "pages#about", as: :about
  get "up" => "rails/health#show", :as => :rails_health_check
end
```

> **해결됨 (구현 후 액션 이름 재정리)**: 초안 단계에서는 액션 이름을 그대로 두고(`index`) 경로만 `/search`로 옮기려 했으나, RESTful 관례상 `index`는 컬렉션의 기본(루트) 목록 액션이어야 한다는 점이 계속 마음에 걸려 최종적으로 액션 이름 자체를 라우트에 맞게 바꿨다: 메인 화면(`/`)이 `index`, 상세 검색(`/search`)이 `search`. 아래 5.2절 코드와 뷰 파일명(`app/views/disease_cases/index.html.erb`/`search.html.erb`)은 이 최종 이름을 반영한다. `root_path`/`search_path` 라우트 헬퍼 이름과 동작 자체는 바뀌지 않았다.

### 5.2 컨트롤러 구조

**`DiseaseCasesController`**의 액션 구성 (최종: `index` = 메인 화면, `search` = 상세 검색):

```ruby
class DiseaseCasesController < ApplicationController
  MAX_SEARCH_RESULTS = 500
  BURDEN_BODY_PART_CHECKBOX_LIMIT = 12

  # / (메인 화면, 직업·부담 신체 부위·사망 여부·신청서 유형 기반 검색)
  def index
    perform_search(legacy: false)
    set_main_filter_options
  end

  # /search (상세 검색, 이전에는 root였다). 메인 화면 필터도 함께 쓸 수 있도록
  # apply_main_filters를 추가로 적용한다.
  def search
    perform_search(legacy: true)
    set_main_filter_options
  end

  def show
    @disease_case = DiseaseCase.find_by(case_no: params[:case_no])
  end

  private

  def perform_search(legacy:)
    if legacy
      @scope, @fallback = DiseaseCase.search(search_params)
      @scope = DiseaseCase.apply_main_filters(@scope, main_search_params)
    else
      @scope, @fallback = DiseaseCase.main_search(main_search_params)
    end
    @pagy, @cases = paginate(@scope)
    @metadata = build_metadata
    log_search_event
  end

  # 체크박스(상위 N개)와 <datalist> 자동완성(전체) 옵션은 같은 집계를 재사용해야 한다 — 각자
  # 따로 DiseaseCase를 pluck하면 GET /·GET /search 접속마다 풀스캔이 두 번씩 돈다(코드 리뷰에서
  # 발견·확인된 회귀).
  def set_main_filter_options
    counts = burden_body_part_token_counts
    @burden_body_part_options = burden_body_part_options(counts)
    @burden_body_part_datalist_options = burden_body_part_datalist_options(counts)
    @application_type_options = application_type_options
  end

  def paginate(scope)
    pagy(scope, items: 12, max_items: MAX_SEARCH_RESULTS)
  end

  # ... (build_metadata, log_search_event 등 기존 유지)

  def main_search_params
    params.permit(
      :q, :job_name, :job_description,
      :death_status, :application_type, :employment_type, :work_type,
      :work_relevance_eval, :sort, :commit, :search,
      :burden_body_part_text,
      burden_body_part: [], ksco_code: []
    )
  end
end
```

> **`/search`에도 재사용**: `apply_main_filters`는 원래 MCP `search_disease_cases` 툴이 legacy `DiseaseCase.search` 결과에 새 구조화 필터를 추가로 적용하려고 public으로 열어둔 메서드였는데(11절 참고), 같은 패턴을 `search` 액션에도 적용해 `/search`(상세 검색)에서도 `/`(메인 화면)와 동일한 직업·부담 신체 부위·사망 여부·신청서 유형 필터를 함께 쓸 수 있게 했다. `main_search_params`가 permit하는 `:q`/`:sort` 등은 `apply_main_filters`가 읽지 않으므로 그대로 재사용해도 무해하다.

### 5.3 검색 Concern 분리

기존 `DiseaseCases::Searchable`는 `/search` (legacy)용으로 그대로 유지.
새 concern `DiseaseCases::MainSearchable`를 생성하여 `/` (main)용 로직을 분리.
> **리팩토링 주의**: `normalize_query`, `build_fts_query`, `sanitize_sql_like` 기반 substring fallback 등은 두 concern에서 **동일한 로직**이다. 구현 시 `DiseaseCases::Searchable`의 private 메서드를 protected로 변경하거나, 별도 `DiseaseCases::QueryBuilder` 모듈로 추출하여 양쪽 concern에서 `include`/`delegate`로 재사용한다. 코드 중복을 피해야 향후 한국어 파티클 처리, SQL Injection 방지 등의 수정이 한 곳에서만 이루어진다.
> **상수 lookup 주의**: `normalize_query`는 메서드이므로 공유 모듈에 옮기고 `include`해도 ancestry를 통해 정상 호출된다. 하지만 `KOREAN_PARTICLES`는 상수이고, Ruby의 비한정(unqualified) 상수 조회는 호출부의 **lexical scope**를 우선 따른다. 그래서 `KOREAN_PARTICLES`를 `QueryBuilder` 쪽으로 옮기고 `Searchable#build_fts_query`에 남아있는 `token.gsub(KOREAN_PARTICLES, "")` 같은 비한정 참조를 그대로 두면 `include`만으로는 해결되지 않고 `NameError`가 난다. 상수까지 옮기려면 남은 참조를 `DiseaseCases::QueryBuilder::KOREAN_PARTICLES`처럼 완전한 이름으로 바꾸거나, 더 안전하게 이번에는 `KOREAN_PARTICLES` 상수는 그대로 두고 `normalize_query` 메서드만 공유 모듈로 추출한다.

```ruby
# app/models/concerns/disease_cases/main_searchable.rb (실제 구현, 초기 설계안에서 세부 수정됨)
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
      # 실제로 DiseaseCasesController#index(/search)도 이 메서드를 재사용한다 (5.2절 참고).
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
        # burden_body_part_text(체크박스 상위 12개 밖의 값을 <datalist> 자동완성으로 찾는 자유
        # 입력, 3.2절 참고)도 같은 values 배열에 합쳐서 동일한 매칭 규칙을 그대로 적용한다.
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
        job_description,
        main_reasoning,
        other_harmful_factors,
        aggravating_factors,
        content='disease_cases',
        content_rowid='id',
        tokenize='unicode61'
      );
    SQL

    # 구현 중 실제로 발생한 치명적 버그: disease_cases에 이미 61,815건이 존재하는 상태에서 위
    # CREATE VIRTUAL TABLE만 실행하면 shadow index가 비어있는 채로 남는다. 그 상태에서 트리거
    # 없이 바로 아래 update/delete 트리거를 만들고 임포트 rake task로 기존 레코드를 UPDATE하면,
    # "색인된 적 없는 rowid"에 대해 delete pseudo-row를 시도하게 되어 FTS5 내부 색인이 깨진다
    # (SQLite3::CorruptException: database disk image is malformed — 전체 disease_cases 테이블
    # UPDATE가 즉시 이 예외로 실패했다). 트리거를 만들기 전에 반드시 먼저 rebuild로 현재 상태를
    # 색인해야 한다.
    execute <<~SQL
      INSERT INTO disease_cases_extracted_fts(disease_cases_extracted_fts) VALUES('rebuild');
    SQL

    # INSERT/UPDATE/DELETE triggers (기존 패턴과 동일)
    execute <<~SQL
      CREATE TRIGGER disease_cases_extracted_fts_insert
      AFTER INSERT ON disease_cases BEGIN
        INSERT INTO disease_cases_extracted_fts(
          rowid, job_name, job_description, main_reasoning,
          other_harmful_factors, aggravating_factors
        ) VALUES (
          new.id, new.job_name, new.job_description, new.main_reasoning,
          new.other_harmful_factors, new.aggravating_factors
        );
      END;
    SQL

    # UPDATE/DELETE triggers는 db/migrate/20260326000002_create_disease_cases_fts.rb의
    # disease_cases_fts_delete/disease_cases_fts_update 트리거와 동일한 패턴(delete pseudo-row 후 재삽입)을
    # 위 5개 컬럼(job_name, job_description, main_reasoning, other_harmful_factors, aggravating_factors)으로 그대로 적용한다.
  end
end
```

---

## 6. 필터 명세 (메인 검색 화면)

### 6.1 필터 UI 구성

| 필터 | 입력 방식 | 대상 컬럼/관계 | 비고 |
|------|----------|---------------|------|
| **직업 (직종명)** | 텍스트 입력 + KSCO 자동완성 | `job_name` (FTS5) / `ksco_codes` (JOIN) | KSCO 선택 시 해당 코드 연결된 판정서 검색 |
| **하는일 (담당 업무)** | 텍스트 입력 | `job_description` (FTS5) | 한국어 조사 제거 적용 |
| **아픈 신체 부위** | 체크박스(빈도 상위 12개) + `<datalist>` 자동완성 텍스트 입력(`burden_body_part_text`) | `burden_body_part` (파이프 구분 다중값) | 단일 exact match도 단순 `LIKE '%값%'`도 아님 — "목"이 "손목"/"발목"/"뒷목"까지 잘못 매칭되지 않도록 파이프 경계 인식 LIKE로 매칭 (5.3절). 실 데이터 distinct 토큰이 1,174개라 전부 체크박스로 못 내서, 상위 12개만 체크박스로 두고 나머지는 네이티브 `<datalist>`로 자동완성 (3.2절 참고) |
| **신청서 유형** | 드롭다운 | `application_type` | 정규화된 enum 값 |
| **사망 여부** | 스위치 / 체크박스 | `death_status` | Y/N |
| **Full-text 검색** | 텍스트 입력 | `disease_cases_extracted_fts` (5개 컬럼) | 기존 FTS5 패턴 재사용 |
| **심의결과** | 드롭다운 (기존 유지) | `result` | 메인 화면에서도 노출 가능 (선택 사항) |
| **정렬** | 라디오 버튼 | relevance / recent | BM25 (FTS5) 또는 `year DESC` |

> **해결됨**: 이 표의 6개 필터(직업 텍스트 필터 2개, 아픈 신체 부위, 신청서 유형, 사망 여부)는 `apply_main_filters` 재사용을 통해 `/search`(상세 검색) 화면에도 그대로 추가되어, 기존 심의결과·질병분류·신체부위·판정일 필터와 조합해 쓸 수 있다 (5.2절 참고). KSCO 코드 필터(`ksco_code[]`)는 아직 `/search` 화면에는 UI가 없다(계층형 자동완성 UI 자체가 8.1절처럼 2차 구현 대기 중).

### 6.2 KSCO 필터 상호작용

1. 사용자가 "버스 운전원" 입력.
2. 자동완성이 `KscoCode.where("name LIKE ?", "버스 운전원%")`로 제안.
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
        name: row["세분류"].to_s.strip,
        minor: row["소분류"].to_s.strip,
        submajor: row["중분류"].to_s.strip,
        major: row["대분류"].to_s.strip,
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

      # 1. 기존 DiseaseCase 속성 업데이트 (숫자 필드는 반드시 to_i/to_d로 저장 — job_tenure_months/max_item_weight/
      #    daily_total_weight는 wip/cerebras_prompts.rb 추출 스키마상 숫자이므로 문자열로 남기지 않는다)
      record.update!(
        job_name: row["직종명"].to_s.strip,
        job_description: row["담당_업무"].to_s.strip,
        employment_type: row["고용_형태"].to_s.strip,
        work_type: row["근무_형태"].to_s.strip,
        job_tenure_months: row["현_직종_총_종사기간"].to_s.strip.presence&.to_i,
        weekly_work_hours: row["1주_평균_근무시간"].to_s.strip.presence&.to_d,
        daily_work_hours: row["1일_평균_근무시간"].to_s.strip.presence&.to_d,
        burden_body_part: row["부담_신체_부위"].to_s.strip,
        bad_posture: row["주요_부적절한_자세"].to_s.strip,
        heavy_lifting: row["중량물_취급_여부"].to_s.strip,
        max_item_weight: row["취급_물품_최대_무게"].to_s.strip.presence&.to_d,
        daily_total_weight: row["1일_취급_총_누적_중량"].to_s.strip.presence&.to_d,
        other_harmful_factors: row["기타_유해요인_노출"].to_s.strip,
        work_relevance_eval: row["업무관련성_평가"].to_s.strip,
        aggravating_factors: row["업묵부담_가중요인_노출"].to_s.strip,
        main_reasoning: row["판단_주요_근거"].to_s.strip,
        death_status: row["사망_여부"].to_s.strip,
        application_type: row["신청서_종류"].to_s.strip
      )

      # 1-1. 최종_산재_인정_여부와 기존 result 비교 — 덮어쓰지 않고 불일치만 로그
      #      (import_disease_cases.rake의 전역 상수 RESULT_MAP을 그대로 재사용)
      extracted_result_raw = row["최종_산재_인정_여부"].to_s.strip
      extracted_result = RESULT_MAP[extracted_result_raw]
      if extracted_result && record.result.present? && record.result != extracted_result
        warn "result 불일치 (case_no=#{case_no}): 기존=#{record.result} 추출=#{extracted_result}"
      end

      # 2. KSCO 매핑 동기화 (JSON 파싱) — 이번 CSV의 ksco_codes_json을 "전체 목표 집합"으로 취급한다.
      #    이 데이터는 추출 프롬프트/모델이 개선될 때마다 재추출·재임포트되므로, upsert만 하면
      #    이전에 붙었지만 이번에는 빠진 코드가 그대로 남아 ksco_code 필터가 오래된(false positive)
      #    매핑까지 매칭하게 된다. 그래서 매번 "현재 JSON에 없는 매핑은 제거"까지 함께 수행한다.
      # 주의: current_codes는 "이번 JSON에 언급된 코드 전체"여야 한다 — KscoCode 테이블에 아직
      # 없어서 skip한 코드도 포함해야 한다. 그렇지 않으면(= 실제로 attach에 성공한 코드만 넣으면)
      # 참조 데이터(KscoCode)가 아직 불완전할 뿐인데 그 코드에 대한 기존 매핑까지 destroy_all로
      # 지워버려, 복구 가능한 참조 데이터 누락이 데이터 손실(및 ksco_code 필터의 false negative)로 이어진다.
      ksco_json = row["ksco_codes_json"].to_s.strip
      if ksco_json.present?
        parsed =
          begin
            JSON.parse(ksco_json)
          rescue JSON::ParserError => e
            warn "ksco_codes_json 파싱 실패, KSCO 매핑 동기화 건너뜀 (case_no=#{case_no}): #{e.message}"
            nil
          end

        if parsed
          current_codes = []
          parsed.each do |item|
            code = item["ksco_code"].to_s.strip
            next if code.blank?

            current_codes << code

            ksco = KscoCode.find_by(code: code)
            unless ksco
              warn "KSCO 코드 없음: #{code} (case_no=#{case_no}) — 매핑은 유지, 참조 데이터 보완 후 재실행 필요"
              next
            end

            record.disease_case_ksco_codes.find_or_initialize_by(ksco_code_id: code).update!(
              similarity: item["similarity"].to_f
            )
          end

          # JSON 파싱에 성공했을 때만 "이번 JSON에 없는 매핑 제거"를 수행한다.
          record.disease_case_ksco_codes.where.not(ksco_code_id: current_codes).destroy_all
        end
      end
      # ksco_codes_json이 비어있거나 파싱 실패한 행은 삭제 동기화를 건너뛴다. 추출이 KSCO 필드를
      # 누락했는지, 형식이 깨졌는지, 아니면 정말 "매칭 없음"인지 CSV만으로는 구분할 수 없으므로,
      # "비어있음 = 매핑 없음"으로 단정해 기존 매핑을 지우지 않는다 (안전한 기본값).
      # 추출기가 "빈 값은 항상 KSCO 매칭 없음을 의미한다"를 보장하게 되면, 이 가드를 없애고
      # 빈 값에서도 destroy_all이 실행되도록 바꿀 수 있다.

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

> **주의**: `ksco_codes_json`에 포함된 코드가 `KscoCode` 테이블에 없는 경우가 있을 수 있다 (CSV가 완전하지 않을 수 있음). 이 경우 `warn`만 남기고 해당 코드의 조인 row는 만들지 않지만, `current_codes`에는 여전히 포함시켜 이후 `destroy_all`이 그 코드에 대한 **기존** 매핑까지 지우지 않도록 한다 — 참조 데이터 누락과 "이번 추출에서 실제로 빠짐"을 구분해야 재발급된 `KscoCode`로 재실행했을 때 데이터가 복구된다.
> **주의**: 위 코드가 참조하는 `RESULT_MAP`은 `lib/tasks/import_disease_cases.rake` 최상단에 정의된 전역 Ruby 상수를 그대로 재사용한다 (rake 파일이 로드되면 `namespace` 블록 밖의 최상위 상수는 전역으로 접근 가능). 별도로 다시 정의하지 않는다.
> **해결됨**: 이전 버전은 `ksco_codes_json`이 비어있어도 `destroy_all`을 무조건 실행해 해당 판정서의 모든 기존 KSCO 매핑을 지웠다. 위 코드는 `ksco_json.present?`이고 JSON 파싱이 성공했을 때만 `destroy_all`을 실행하도록 가드를 추가했다 — 빈 값/파싱 실패를 "매칭 없음"으로 단정하지 않고 기존 매핑을 보존한다.

---

## 8. UI/UX 개요

### 8.1 메인 화면 (`app/views/disease_cases/index.html.erb`, 초안에서는 `main.html.erb`)

- **Hero 검색창**: 큰 텍스트 입력 (Full-text) + 검색 버튼.
- **필터 패널** (화면 좌측 또는 상단 아코디언):
  - 직업: 텍스트 입력 + KSCO 자동완성 드롭다운.
  - 하는일: 텍스트 입력.
  - 아픈 신체 부위: 체크박스 그룹 (기존 `body_part` UI와 유사).
  - 신청서 유형: 셀렉트 박스.
  - 사망 여부: 토글 스위치 (Y/N).
  - KSCO 계층: 대분류 → 중분류 → 소분류 → 세분류 연동 셀렉트 (선택 사항, 2차 구현).
- **결과 목록**: 카드 또는 테이블 형태. 각 항목에 직종명, 담당업무 요약, 신청서 유형, 사망 여부 배지 표시.
- **페이지네이션**: `pagy` 재사용.

> **해결됨 (구현 중 변경)**: 초안에는 결과 목록에 KSCO 코드 태그도 넣기로 했으나, 판정서 하나가 여러 KSCO 코드에 매핑될 수 있어 태그가 한 줄을 과도하게 길게 만들어 가독성을 해쳤다. 목록에서는 빼고(판정서 상세 화면에는 그대로 남아있음), 더 이상 렌더링하지 않으므로 컨트롤러의 관련 eager load(`includes(:ksco_codes)`)도 함께 제거했다.
> **해결됨 (구현 중 변경)**: 사망 여부 배지는 처음에 체크박스 라벨("사망 사례만 보기")을 그대로 재사용해 목록 각 행마다 반복 노출되고 `<mark>` 기본 음영까지 붙는 버그가 있었다. 배지 전용 로케일 키(`death_badge`, "사망")로 분리하고 `<span>`으로 고쳤다.

### 8.2 기존 검색 화면 이동 (`app/views/disease_cases/search.html.erb`, 초안/구현 초기에는 `index.html.erb`)

- `form_with url: search_path`로 변경.
- 기존 UI(검색 대상 컬럼, 심의결과, 질병분류, 신체부위, 판정일, 정렬)는 그대로 유지.

> **해결됨 (구현 중 추가)**: 초안에는 없었지만, `/search`에 `/`(메인 화면)의 필터를 함께 노출해달라는 후속 요청으로 `job_name`/`job_description` 텍스트 필드, `burden_body_part` 체크박스(상위 12개)+`<datalist>` 자동완성, `application_type` 드롭다운, `death_status` 토글을 메인 화면 뷰와 동일한 마크업으로 상세 검색 뷰에 추가했다(5.2절의 컨트롤러 재사용과 짝을 이룬다). 기존 필터와 시각적으로 구분하기 위해 새 필드들은 각각 관련 있는 기존 필드 근처(신체부위 체크박스 다음에 부담 신체 부위, 판정일 다음에 신청서 유형/사망 여부)에 배치했다.
> **참고 (액션 이름 재정리)**: 5.1절에서 설명한 것처럼 컨트롤러 액션 이름을 나중에 재정리하면서 뷰 파일명도 함께 바뀌었다 — 메인 화면 뷰는 `main.html.erb` → `index.html.erb`로, 상세 검색 뷰는 `index.html.erb` → `search.html.erb`로 옮겨졌다(이름이 서로 맞바뀐 것이라 혼동하기 쉽다).

### 8.3 레이아웃 네비게이션 수정 (`app/views/layouts/application.html.erb`)

`root_path`가 새 메인 화면(`disease_cases#index`)을 가리키게 되므로, 상단 내비게이션의 "검색" 링크는 `search_path`로 명시적으로 변경해야 한다. "업무상 질병 판정서" 브랜드 링크와 "검색" 링크가 동일한 URL을 가리키는 상황을 방지하고, 사용자가 기존 전문 검색(`/search`)에 접근할 수 있도록 유지한다.

```erb
<%= link_to t("nav.search"), search_path %>
```

---

## 9. 구현 단계

### Phase 1: 모델 및 마이그레이션 (1~2일)

1. [x] `KscoCode` 모델 + 마이그레이션 생성
2. [x] `DiseaseCaseKscoCode` 조인 모델 + 마이그레이션 생성
3. [x] `DiseaseCase` 확장 마이그레이션 (18개 신규 컬럼 + 인덱스)
4. [x] `disease_cases_extracted_fts` FTS5 가상 테이블 + 트리거 마이그레이션
5. [x] `DiseaseCase` 모델에 `has_many :disease_case_ksco_codes` 등 관계 추가 (`dependent: :delete_all` — 4.2절 참고)
6. [x] `DiseaseCases::MainSearchable` concern 신규 생성 (기존 `Searchable`는 그대로 유지)

### Phase 2: 데이터 임포트 (1일)

7. [x] `import:ksco_codes` rake task 작성 및 실행
8. [x] `import:extracted_disease_cases` rake task 작성 및 실행
9. [x] 데이터 검증: `DiseaseCase.where(job_name: nil).count` 등으로 누락 확인

### Phase 3: 라우팅, 컨트롤러 및 MCP Tool (0.5~1일)

10. [x] `routes.rb` 변경: `root` → `disease_cases#main`, `/search` → `disease_cases#index` — **이후 액션 이름을 라우트 관례에 맞게 재정리**: `root` → `disease_cases#index`, `/search` → `disease_cases#search` (5.1절 참고)
11. [x] `DiseaseCasesController#main` 액션 추가 — 이후 `#index`로 이름 변경 (5.1절)
12. [x] `main_search_params` strong parameters 정의
13. [x] 기존 `index.html.erb`의 `form_with url:`을 `search_path`로 수정 — 이후 이 파일은 `search.html.erb`로 이름이 바뀜 (8.2절)
14. [x] `app/mcp/tools/search_disease_cases_tool.rb` 업데이트: `job_name`, `job_description`, `ksco_code`, `death_status` 파라미터 노출, ad-hoc 키워드 매칭을 새 구조화 필터로 대체/보완

### Phase 4: UI 개발 (2~3일)

15. [x] `main.html.erb` 신규 작성 (필터 패널 + 결과 목록)
16. [ ] KSCO 자동완성 Stimulus 컨트롤러 (`ksco_autocomplete_controller.js`) — 2차 구현으로 미룸 (1.3절 열린 질문 참고)
17. [x] 필터별 UI 컴포넌트 (체크박스, 셀렉트, 토글, `<datalist>` 자동완성)
18. [x] 결과 카드/테이블 행 디자인 (직종명, 사망 배지) — KSCO 태그는 가독성 문제로 목록에서 제외 (8.1절)
19. [x] Oat CSS 클래스 적용 및 반응형 처리

### Phase 5: 테스트 및 검증 (1일)

20. [x] `main_search` concern 유닛 테스트 (필터 조합, FTS5 fallback)
21. [x] 통합 테스트: `/` 접속 → 필터 적용 → 결과 확인
22. [x] 기존 `/search` 경로 회귀 테스트 (기능 퇴행 확인)
23. [x] MCP Tool 테스트: LLM 클라이언트 시나리오로 `job_name`/`death_status` 필터 정상 동작 확인
24. [x] LSP diagnostics / `rubocop` 통과

### Phase 6: QA·코드 리뷰 후속 수정 (구현 중 추가)

25. [x] `burden_body_part` 체크박스를 빈도 상위 12개로 제한하고 나머지는 `<datalist>` 자동완성으로 전환 (3.2절, 6.1절)
26. [x] 목록의 사망 배지 라벨/음영 버그 수정 (8.1절)
27. [x] 검색 결과 목록에서 KSCO 코드 컬럼 제거 + 관련 eager load 제거 (8.1절)
28. [x] `DiseaseCase#has_many :disease_case_ksco_codes`에 `dependent: :delete_all` 추가 — KSCO 매핑이 있는 판정서 `destroy` 시 FK 오류 나던 버그 수정 (4.2절, 코드 리뷰에서 발견)
29. [x] `/`(메인 화면) 접속 시 `burden_body_part` 토큰 집계를 한 번만 계산하도록 수정 — 체크박스/자동완성 옵션이 각자 풀스캔을 돌리던 회귀 (5.2절, 코드 리뷰에서 발견)
30. [x] `/search`(상세 검색)에 `/`(메인 화면)의 직업·부담 신체 부위·사망 여부·신청서 유형 필터 통합 (5.2절, 8.2절)
31. [x] `DiseaseCasesController` 액션 이름을 라우트 관례에 맞게 재정리: `main` → `index`, `index` → `search` (뷰 파일명도 함께 이동, 5.1절·5.2절·8.1절·8.2절)

---

## 10. 리스크 및 대응

| 리스크 | 영향 | 대응 |
|--------|------|------|
| `burden_body_part` 데이터 누락 다수 | 필터 UI가 비어 보임 | 데이터 profiling 먼저 실행. 누락 시 기존 `body_part`를 fallback 표시하거나, enum 대신 자유 텍스트 필터 + autocomplete로 전환 |
| **해결됨** — `burden_body_part` 실 데이터 distinct 토큰이 1,174개(파이프 split 기준)라 체크박스가 감당 불가능한 수준이었음 | 체크박스 1,000개 이상 렌더링, 화면 사용 불가 | 위 리스크와 별개로 실제 발생한 문제. profiling 결과를 바탕으로 빈도 상위 12개만 체크박스, 나머지는 `<datalist>` 자동완성(`burden_body_part_text`)으로 전환 (3.2절, 6.1절) |
| `ksco_codes_json` 내 코드가 `KscoCode` 테이블에 없음 | JOIN 시 누락 | rake task에서 `warn` 출력 후 무시. 추후 KSCO CSV 보완 |
| FTS5 가상 테이블 2개 동시 유지 | 마이그레이션 복잡도 | 기존/신규 트리거를 별도 마이그레이션 파일로 분리. `db:migrate` 순서 명확히 |
| 기존 검색 경로 변경 | 외부 링크/북마크 깨짐 | README, MCP 문서, `workercare.plan.md` 경로 동시 업데이트. `/`는 그대로 유효하므로 영향 최소 |
| `ksco_codes_json`이 비어있을 때 삭제 동기화를 건너뜀 (7.2절) | 추출 결과가 정말로 "매칭 없음"으로 바뀐 케이스에서 오래된 KSCO 매핑이 남아있을 수 있음 (false positive 가능성) | 의도된 안전한 기본값 — "비어있음"과 "필드 누락/파싱 실패"를 구분할 수 없는 한 삭제보다 보존을 택함. 추출기 계약이 "빈 값 = 매칭 없음 확정"을 보장하게 되면 이 가드를 제거하고 빈 값에서도 `destroy_all`을 실행하도록 전환 |
| 기존 데이터 위에 FTS5 external content 테이블을 새로 추가 | rebuild 없이 트리거만 만들면 기존 레코드 UPDATE 시 FTS5 색인이 깨짐 (`SQLite3::CorruptException`) — 실제 구현 중 발생·확인됨 | 5.4절 마이그레이션에서 `CREATE VIRTUAL TABLE` 직후, 트리거 생성 전에 `INSERT INTO disease_cases_extracted_fts(disease_cases_extracted_fts) VALUES('rebuild')`를 먼저 실행 |
| `SearchDiseaseCasesTool#build_statistics`가 `bm25` ORDER가 걸린 scope에 `.group(:result).count` 호출 | FTS 매칭 결과가 있을 때마다 `SQLite3::SQLException: unable to use function bm25 in the requested context`로 실패 (기존 MCP 테스트는 테스트 DB에 데이터가 없어 항상 fallback 경로만 타서 발견되지 않았던 기존 버그) — 실제 구현 중 발생·확인됨 | `scope.reorder(nil).group(:result).count`로 집계 전 order를 제거 |
| `DiseaseCase#has_many :disease_case_ksco_codes`에 `dependent` 옵션 누락 | KSCO 매핑이 붙은 판정서를 `destroy`하면 DB FK 제약 위반(`ActiveRecord::InvalidForeignKey`)으로 삭제 실패 — 코드 리뷰에서 발견·재현 확인됨 | `dependent: :delete_all` 추가, 재현 테스트(`test/models/disease_case_test.rb`) 추가 (4.2절) |
| `burden_body_part_options`/`burden_body_part_datalist_options`가 각자 같은 토큰 집계 쿼리를 호출 | `/`·`/search` 접속마다 `burden_body_part` 전체 pluck + 파이프 split 풀스캔이 두 번씩 실행 — 코드 리뷰에서 발견·확인됨 | 컨트롤러 액션에서 한 번만 계산해 두 메서드에 전달·재사용하도록 수정, SQL 쿼리 횟수를 검증하는 테스트 추가 (5.2절) |

---

## 11. 결론

- **모델**: 기존 `DiseaseCase`를 확장한다. 1:1 분리는 불필요한 복잡도만 추가한다. `has_many :disease_case_ksco_codes`는 `dependent: :delete_all`로 KSCO 매핑을 캐스케이드 삭제한다(4.2절 — 원래 없었으나 코드 리뷰로 FK 오류가 발견되어 추가).
- **KSCO**: 별도 `KscoCode` + `DiseaseCaseKscoCode` 조인 테이블로 관리.
- **검색**: 기존 `/search` (legacy)는 `DiseaseCases::Searchable` + `disease_cases_fts` 그대로 유지. 새 메인 화면은 `DiseaseCases::MainSearchable` + `disease_cases_extracted_fts`로 분리 구현. `MainSearchable.apply_main_filters`는 `/search`에도 재사용되어(5.2절), 최종적으로 두 화면 모두 직업·부담 신체 부위·사망 여부·신청서 유형 필터를 공유한다.
- **데이터**: `import:ksco_codes` → `import:extracted_disease_cases` 순서로 실행.
- **UI**: 직업/KSCO 중심의 필터 패널 + Full-text Hero 검색창. `burden_body_part`는 실 데이터 distinct 토큰이 1,174개라 상위 12개 체크박스 + `<datalist>` 자동완성으로 최종 확정(3.2절). 검색 결과 목록에서는 KSCO 코드 태그를 뺐다(가독성, 8.1절).
- **MCP**: `app/mcp/tools/search_disease_cases_tool.rb`를 함께 업데이트하여, LLM 클라이언트가 새 `job_name`/`job_description`/`ksco_code[]`/`death_status` 파라미터를 필터로 사용할 수 있도록 한다 (`main_search_params`/`apply_main_filters`가 실제로 읽는 이름은 단수 `ksco_code`이며 배열로 받는다 — MCP 툴도 이 이름을 그대로 써야 하고, `ksco_codes`처럼 다른 이름을 쓰면 `main_search_params`가 값을 버리고 `apply_main_filters`도 읽지 않아 KSCO 필터가 조용히 무시된다). 기존의 `work_match?`/`symptom_match?` 같은 ad-hoc 키워드 매칭은 새 구조화 데이터로 대체하거나 보완한다.

**현재 상태**: 위 Phase 1~6 구현 완료, `feat/search_ksco` 브랜치에서 PR #13으로 리뷰 중. 남은 것은 1절 "열린 질문" 3가지(enum 전환 여부, KSCO 계층형 자동완성 2차 구현, `ksco_codes_json` 빈 값 처리 재검토)와 병합 후 데이터 임포트 실행뿐이다.
