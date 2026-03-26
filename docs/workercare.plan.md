# 산재상담실 workercare — Rails 8 + SQLite + 한국어 업무상질병판정서 검색

## 개요

산업재해 직업병에 대해 업무상질병 판정서를 검색. Rails 8 앱.
SQLite를 DB로 사용하며, FTS5 virtual table로 한국어 전문 검색(full-text, substring) 구현.
성능을 위해 `mmap_size` pragma로 SQLite 파일을 OS 페이지 캐시에 유지.

UI 라이브러리는 tailwindcss 대신 oat(https://oat.ink/) 사용

---

## 1. 프로젝트 생성

```bash
rails new . -name workercare --database=sqlite3 --skip-test
```

---

## 2. 데이터: 근로복지공단 업무상질병 판정서

### 원본 CSV (참고용 샘플)

`comwel-list-sample.csv`
연번, 신청질병, 심의결과, 심의연도, 질병분류, 신체부위, 링크

`comwel-case-sample.csv`
연번, 신청질병, 심의결과, 심의연도, 질병분류, 신체부위, 주문, 청구 취지, 신청 내용, 신청인 주장, 진료기록 및 의학적 소견, 인정 사실, 관계 법령, 위원회 판단 및 결론

### 병합 전략

`comwel_disease_cases.csv`(판정서 본문)와 `comwel_list.csv`(목록)를 **단일 테이블** `disease_cases`로 통합.
`연번`을 조인 키로 사용. `comwel_list.csv`는 대부분 컬럼이 중복이므로 `링크` 컬럼만 활용.
`case_id` 별도 컬럼 없음 — `case_no`(연번)이 식별자 역할. 외부 링크 표시 시 `case_no` 사용.
`판정일` 컬럼 실제 존재 확인됨 → `decided_on` 컬럼 사용.

### DB 컬럼 (Rails snake_case)

| 컬럼명 | 원본 | 비고 |
|--------|------|------|
| `case_no` | 연번 | |
| `disease_name` | 신청질병 | substring 검색 |
| `result` | 심의결과 | substring 검색 |
| `year` | 심의연도 | 필터 |
| `disease_category` | 질병분류 | substring 검색 |
| `body_part` | 신체부위 | substring 검색 |
| `link` | 링크 | 외부 URL 원본 |
| `statement` | 주문 | |
| `claim_purpose` | 청구 취지 | |
| `application_content` | 신청 내용 | **fulltext** |
| `applicant_claim` | 신청인 주장 | **fulltext** |
| `medical_records` | 진료기록 및 의학적 소견 | **fulltext** |
| `recognized_facts` | 인정 사실 | **fulltext** |
| `related_laws` | 관계 법령 | |
| `committee_decision` | 위원회 판단 및 결론 | **fulltext** |
| `decided_on` | 판정일 | 기간 검색용 ※ |

> ※ `decided_on`: 실제 CSV에 존재 확인됨.

### Enum 설계 (Rails string enum + prefix + i18n)

DB에는 영어 키 값 저장. 화면 표시는 locale 파일로 처리.

```ruby
# app/models/disease_case.rb

enum :result, {
  approved:           "approved",
  rejected:           "rejected",
  partially_approved: "partially_approved",
  revised_approved:   "revised_approved"
}, prefix: true

enum :disease_category, {
  musculoskeletal: "musculoskeletal",
  other_disease:   "other_disease",
  hearing_loss:    "hearing_loss",
  cardiovascular:  "cardiovascular",
  cancer:          "cancer",
  pneumoconiosis:  "pneumoconiosis",
  respiratory:     "respiratory"
}, prefix: true

enum :body_part, {
  chest_back:        "chest_back",
  ear:               "ear",
  other:             "other",
  eye:               "eye",
  leg:               "leg",
  head:              "head",
  neck:              "neck",
  foot:              "foot",
  abdomen:           "abdomen",
  multiple:          "multiple",
  urogenital:        "urogenital",
  digestive:         "digestive",
  hand:              "hand",
  circulatory:       "circulatory",
  nervous_system:    "nervous_system",
  face:              "face",
  hip:               "hip",
  whole_body:        "whole_body",
  arm:               "arm",
  lower_back:        "lower_back",
  respiratory_organ: "respiratory_organ"
}, prefix: true
```

### Locale 파일 (다국어 패턴: `activerecord.attributes.ModelName/enum_name_enum.key`)

```yaml
# config/locales/models/disease_case/en.yml
en:
  activerecord:
    attributes:
      disease_case/result_enum:
        approved:           "Approved"
        rejected:           "Rejected"
        partially_approved: "Partially Approved"
        revised_approved:   "Revised Approved"
      disease_case/disease_category_enum:
        musculoskeletal: "Musculoskeletal"
        other_disease:   "Other Disease"
        hearing_loss:    "Hearing Loss"
        cardiovascular:  "Cardiovascular"
        cancer:          "Cancer"
        pneumoconiosis:  "Pneumoconiosis"
        respiratory:     "Respiratory"
      disease_case/body_part_enum:
        chest_back:        "Chest / Back"
        ear:               "Ear"
        other:             "Other"
        eye:               "Eye"
        leg:               "Leg"
        head:              "Head / Brain"
        neck:              "Neck"
        foot:              "Foot / Toes"
        abdomen:           "Abdomen"
        multiple:          "Multiple Sites"
        urogenital:        "Urogenital"
        digestive:         "Digestive"
        hand:              "Hand / Fingers"
        circulatory:       "Circulatory"
        nervous_system:    "Nervous System"
        face:              "Face"
        hip:               "Hip"
        whole_body:        "Whole Body"
        arm:               "Arm"
        lower_back:        "Lower Back"
        respiratory_organ: "Respiratory Organ"
```

```yaml
# config/locales/models/disease_case/ko.yml
ko:
  activerecord:
    attributes:
      disease_case/result_enum:
        approved:           "인정"
        rejected:           "불인정"
        partially_approved: "일부인정"
        revised_approved:   "변경인정"
      disease_case/disease_category_enum:
        musculoskeletal: "근골격계질병"
        # ...
```

### HumanEnumerable concern (다국어 패턴)

```ruby
# app/models/concerns/human_enumerable.rb
module HumanEnumerable
  extend ActiveSupport::Concern

  included do
    def human_attribute_enum(attribute, variant = nil, options = {})
      self.class.human_attribute_enum(attribute, self[attribute], variant, **options)
    end
  end

  class_methods do
    def human_attribute_enum(attribute, key, variant = nil, options = {})
      value_options = options.dup
      attribute = "#{attribute}_enum"
      if value_options[:default].blank?
        default_options = value_options.dup
        default_options[:default] = key
        value_options[:default] = human_attribute_name([attribute, variant, :undefined].compact_blank.join("."), **default_options)
      end
      human_attribute_name([attribute, variant, key].compact_blank.join("."), **value_options)
    end

    def enum_options_for_select(attribute, options = {})
      onlys    = (options.delete(:only)    || []).compact.map!(&:to_s)
      excludes = (options.delete(:exclude) || []).compact.map!(&:to_s)
      send(attribute.to_s.pluralize).keys.filter_map do |key|
        next if onlys.present?    && onlys.exclude?(key)
        next if excludes.present? && excludes.include?(key)
        [human_attribute_enum(attribute, key, **options), key]
      end.to_h
    end
  end
end
```

뷰에서 사용:
```erb
<%= record.human_attribute_enum(:result) %>
<%= record.human_attribute_enum(:body_part) %>
```

셀렉트박스:
```erb
<%= f.select :result, DiseaseCase.enum_options_for_select(:result) %>
```

CSV 임포트 시 원본 한국어 값 → enum key 변환 필요 (rake task에서 처리):
```ruby
RESULT_MAP = { "인정" => "approved", "불인정" => "rejected",
               "일부인정" => "partially_approved", "변경인정" => "revised_approved" }
```

prefix 사용 예시:
- `DiseaseCase.result_approved` — 인정 건만
- `record.result_rejected?` — 불인정 여부
- `DiseaseCase.category_cardiovascular` — 뇌심혈관계 건만
- `DiseaseCase.body_lower_back` — 허리 건만

DB 컬럼 타입: `string`

---

## 3. SQLite FTS5 가상 테이블

**fulltext 인덱스 대상 컬럼 (5개):**
- `application_content`, `applicant_claim`, `medical_records`, `recognized_facts`, `committee_decision`

**포인트:**
- `unicode61` tokenizer — 한국어 유니코드 문자 단위 인덱싱
- content table 방식 — 원본 데이터 중복 없이 FTS 인덱스만 유지
- trigger 대상: `disease_cases` 테이블의 INSERT/UPDATE/DELETE
  - 3개 trigger (INSERT/UPDATE/DELETE)

**LIKE fallback 성능:**
- `disease_name LIKE '%허리%'` — leading wildcard로 인덱스 사용 불가, full scan 발생
- 대응: fallback 자체를 최소화(FTS 품질 향상)가 근본 해결책
- 보조: `CREATE INDEX idx_disease_cases_disease_name ON disease_cases(disease_name)` — full scan 비용 소폭 절감(페이지 수 감소), leading wildcard에는 효과 제한적

### 쿼리 전처리 (FTS5 입력 정규화)

입력 → normalize → FTS5 MATCH 쿼리 생성 → 결과 없으면 substring fallback

```ruby
# app/services/disease_case_search.rb

# 복합 조사를 먼저 — 순서 중요 ("으로"가 "로"보다 앞에 와야 함)
KOREAN_PARTICLES = /(으로|에서|까지|부터|은|는|이|가|을|를|의|로|도|만|와|과)$/

def normalize_query(raw)
  raw.to_s
     .unicode_normalize(:nfkc)   # 전각/반각 통일
     .gsub(/\s+/, " ").strip
end

def build_fts_query(raw)
  q = normalize_query(raw)
  return nil if q.blank?

  q.split(" ")
   .first(5)                                        # 토큰 최대 5개 — 긴 입력 시 성능 보호
   .map { |token| token.gsub(KOREAN_PARTICLES, "") }
   .reject(&:blank?)
   .map { |token|
     # ⚠️ FTS5 MATCH 구문 내 큰따옴표 이스케이프 — syntax error 방지
     # FTS5에서 " 는 구절 경계 구분자 → 토큰 내 " 는 "" 로 이스케이프
     escaped = token.gsub('"', '""')
     "\"#{escaped}\""
   }
   .join(" AND ")
end
# "요통 치료" → '"요통" AND "치료"'
# "허리통증이" → '"허리통증"'
# "사무실에서" → '"사무실"'
# 'OR 1=1' → '"OR" AND "1=1"' (연산자 키워드 무력화)
```

**검색 흐름:**
1. FTS5 MATCH (AND 쿼리) 시도
2. 결과 0건이면 scope를 `DiseaseCase.all`로 **초기화 후** substring fallback
   - ⚠️ 초기화 없으면 FTS JOIN이 유지된 상태에서 LIKE 실행 → 잘못된 결과
3. LIKE는 fallback 전용 — 기본 검색에는 사용 안 함

```ruby
# 서비스 객체 내 흐름
scope = DiseaseCase.fulltext(fts_query)
if scope.empty?
  scope = substring_fallback(tokens)  # DiseaseCase.all 베이스로 새로 시작
  @fallback = true
end
```

**Substring fallback (토큰 최대 2개 AND):**
```ruby
def substring_fallback(tokens)
  # ActiveRecord::Base.sanitize_sql_like — LIKE wildcard(%, _) 이스케이프
  safe_tokens = tokens.first(2).map { |t| ActiveRecord::Base.sanitize_sql_like(t) }
  conditions = safe_tokens.map { "disease_name LIKE ?" }.join(" AND ")
  binds = safe_tokens.map { |t| "%#{t}%" }
  DiseaseCase.where(conditions, *binds)
end
# ["허리", "통증"] → disease_name LIKE '%허리%' AND disease_name LIKE '%통증%'
```

---

## 4. 성능: mmap 방식 메모리 활용

`:memory:` 복사 대신 `mmap_size` pragma 사용.
61,815건 × 평균 ~10KB = 약 600MB 예상. 초기값 256MB로 시작, 부족하면 512MB → 1GB로 늘림.

```ruby
# config/initializers/sqlite_mmap.rb
db = ActiveRecord::Base.connection
db.execute("PRAGMA mmap_size=#{256 * 1024 * 1024}")  # 256MB (시작값)
db.execute("PRAGMA cache_size=-32768")               # 32MB page cache
db.execute("PRAGMA journal_mode=WAL")
db.execute("PRAGMA synchronous=NORMAL")
```

OS 페이지 캐시가 자동으로 핫 데이터를 RAM에 유지. 파일 원본 보존됨.
부하 테스트 후 `mmap_size` 단계적 증가: 256MB → 512MB → 1GB.

---

## 5. 검색 서비스

### 검색 모드

| 모드 | 사용 위치 | 대상 컬럼 | 동작 |
|------|-----------|-----------|------|
| FTS5 fulltext | 메인 검색, 상세 검색 | FTS 인덱스 5개 컬럼 | MATCH `"단어1" AND "단어2"` |
| substring fallback | FTS 결과 0건일 때만 | `disease_name` | `LIKE '%첫번째토큰%'` |

LIKE는 기본 검색에 사용하지 않음. fallback 전용.

### 체이닝 가능 구조 (모델 scope)

```ruby
# app/models/disease_case.rb

scope :fulltext, ->(q) {
  return all unless q.present?

  joins("JOIN disease_cases_fts fts ON fts.rowid = disease_cases.id")
    .where("fts MATCH ?", q)
}

# 사용 예
# DiseaseCase.fulltext(q)

scope :by_result,   ->(v) { where(result: v) if v.present? }
scope :by_year,     ->(y) { where(year: y) if y.present? }
scope :by_category, ->(c) { where(disease_category: c) if c.present? }
scope :by_body,     ->(b) { where(body_part: b) if b.present? }

# from/to 각각 nil 허용
scope :by_date_range, ->(from, to) {
  if from && to
    where(decided_on: from..to)
  elsif from
    where("decided_on >= ?", from)
  elsif to
    where("decided_on <= ?", to)
  end
}
```

**컨트롤러는 얇게 — 로직은 모델/서비스에 집중:**

```ruby
# 컨트롤러 (thin)
def index
  @search = DiseaseCaseSearch.new(search_params)
  @over_cap, @result_count, @pagy, @cases = @search.paginated_results
end

private

def search_params
  params.permit(:q, :result, :year, :disease_category, :body_part,
                :decided_on_from, :decided_on_to, :sort)
end
```

```ruby
# DiseaseCaseSearch 서비스가 담당:
# - 쿼리 전처리 (normalize, build_fts_query)
# - scope 체이닝 (fulltext, by_result, by_year, ...)
# - bm25 정렬 판단 (fts_query.present? 조건)
# - 500건 캡 + 건수/초과 여부
# - fallback 여부 추적
# - pagy_array 반환
```

### 정렬

- 기본: `year DESC` (최신순)
- 전문검색 결과: BM25 관련도 — FTS5 내장 `bm25()` 함수 사용
- `ORDER BY rank` (FTS5 alias)는 동작하지 않는 경우 있음 → 명시적으로 `bm25()` 사용
- **⚠️ 규칙: `bm25()` 는 fulltext scope JOIN 있을 때만 적용. q.present? 조건 필수.**

```ruby
# 관련도 정렬 (FTS JOIN 있을 때만)
scope.order(Arel.sql("bm25(disease_cases_fts)"))

# 최신순 정렬
scope.order(year: :desc)
```

- 컨트롤러에서 `sort` 파라미터로 선택 가능 (`relevance` / `recent`)

### bm25 컬럼 가중치

컬럼 순서: `application_content`, `applicant_claim`, `medical_records`, `recognized_facts`, `committee_decision`

```ruby
# 위원회 판단·결론 및 진료기록에 높은 가중치
scope.order(Arel.sql("bm25(disease_cases_fts, 1.0, 0.5, 2.0, 1.5, 1.5)"))
```

| 컬럼 | weight | 근거 |
|------|--------|------|
| application_content | 1.0 | 기본 |
| applicant_claim | 0.5 | 주관적 주장 |
| medical_records | 2.0 | 의학적 근거 핵심 |
| recognized_facts | 1.5 | 인정된 사실 |
| committee_decision | 1.5 | 판단·결론 |

### fallback UX

검색 결과 없음 → substring fallback 발생 시 뷰에 안내 메시지 표시:

```ruby
# 서비스 객체가 fallback 여부를 반환
@search = DiseaseCaseSearch.new(params[:q])
@cases  = @search.results
@used_fallback = @search.fallback?
```

```erb
<% if @used_fallback %>
  <p>정확한 결과가 없어 유사한 결과를 보여드립니다.</p>
<% end %>
```

### 검색 로그 대안

DB 테이블 없이 Rails logger로 구조화 로그 출력:

```ruby
Rails.logger.info({
  event:        "search",
  query:        raw_query,
  result_count: results.count,
  used_fallback: fallback?
}.to_json)
```

→ `log/production.log`에 JSON 라인으로 기록.
→ `grep '"event":"search"' log/production.log | jq .` 로 즉시 분석 가능.
→ 테이블/마이그레이션 없음. 나중에 필요하면 DB로 이관.

### 상세 검색 필터

- `disease_name` — 신청질병 (FTS fallback 또는 exact prefix)
- `result` — 심의결과 (enum exact)
- `year` — 심의연도 (exact)
- `disease_category` — 질병분류 (enum exact)
- `body_part` — 신체부위 (enum exact)
- `decided_on` — 판정일 기간 (between), null 허용 → fallback `by_year`

```ruby
# decided_on 없는 경우 fallback
scope :by_year, ->(y) { where(year: y) if y.present? }
# decided_on 있는 경우
scope :by_date_range, ->(from, to) { where(decided_on: from..to) if from || to }
```

---

## 6. 검색 UI

### 라우트

```
GET /                          → 메인 검색 (fulltext)
GET /search                    → 상세 검색 (fulltext + substring + 필터)
GET /disease_cases/:id         → 판정서 상세 페이지
```

### Pagination

검색 결과를 최대 300건으로 제한. 301건을 fetch해서 초과 여부를 판단.
- 301건 미만 → 실제 건수 표시
- 301건 이상 → "300건 초과" 표시, 301번째는 버림
- 300을 magic number 이고 constanct 관리

```ruby
# 모델 scope
scope :capped, -> { limit(501) }

# 서비스 객체 내
raw = scope.capped.to_a
@over_cap   = raw.size > 500
@result_count = @over_cap ? nil : raw.size
results = raw.first(500)
@pagy, @cases = pagy_array(results)
```

```erb
<%# 뷰 — 건수 표시 %>
<% if @over_cap %>
  <p>500건 초과 — 검색어를 구체화하세요.</p>
<% else %>
  <p><%= @result_count %>건</p>
<% end %>
<%== pagy_nav(@pagy) %>
```

> `pagy_array`는 배열 기반 페이지네이션 — pagy 기본 제공. COUNT 쿼리 없음.

### 메인 페이지 (`/`)
- 검색창 하나만 있는 단순 형태
- 입력 → fulltext 검색 → 결과 목록 (pagy 페이지네이션)
- 결과 항목: `disease_name`, `result`, `year`, `disease_category`, `body_part`
  - 제목(신청질병) 클릭 → 상세 페이지
  - 외부 링크 아이콘 → 근로복지공단 URL (새 탭), 링크 텍스트는 `case_no` (연번)

### 상세 검색 페이지 (`/search`)
- fulltext 검색창 + substring 필드별 검색창
- 필터: 심의결과, 심의연도, 질병분류, 신체부위, 판정일 기간
- 결과 목록: 메인과 동일 형태

### 판정서 상세 페이지 (`/disease_cases/:id`)
- 모든 컬럼 표시
- 외부 링크 (근로복지공단) 버튼

---

## 7. Gemfile 추가

```ruby
gem "pagy"              # 경량 페이지네이션
gem "sqlite3", "~> 2.0" # Rails 8 기본 (FTS5 내장)
gem "rails-i18n"        # ko/en 로케일 번역 파일
```

## 7-0. oat CSS 통합 (importmap CDN)

tailwindcss 대신 oat(https://oat.ink/) 사용. importmap으로 CDN에서 로드.

```ruby
# config/importmap.rb
pin "oat", to: "https://cdn.jsdelivr.net/npm/oat@latest/dist/oat.js"
```

```erb
<%# app/views/layouts/application.html.erb — <head> 안 %>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/oat@latest/dist/oat.css">
<%= javascript_importmap_tags %>
```

- gem 추가 없음 — CDN 직접 참조
- Rails 8 기본 importmap 활용 (추가 설정 불필요)

## 7-1. i18n 로케일 설정

**전략: ko/en 두 언어 모두 지원 (UI 텍스트, enum 레이블)**
- 뷰에서 하드코딩 문자열 없이 `t()` 헬퍼 일관 사용
- 검색(FTS)은 항상 한국어 — locale 파라미터 없음
- URL 기반 locale switching (`/ko/`, `/en/`) 또는 Accept-Language 헤더 활용

```ruby
# config/application.rb
config.i18n.available_locales = [:ko, :en]
config.i18n.default_locale = :ko
```

로케일 파일:
- `config/locales/ko.yml` — 한국어 번역 (기본)
- `config/locales/en.yml` — 영어 번역
- `rails-i18n` gem이 Rails 기본 번역(날짜, 숫자, 오류 메시지) 제공

번역 키 구조 (예시):
```yaml
# ko.yml
ko:
  disease_case:
    disease_name: "신청질병"
    result: "심의결과"
    year: "심의연도"
    disease_category: "질병분류"
    body_part: "신체부위"
    decided_on: "판정일"
    link: "원문"
  search:
    title: "업무상질병 판정서 검색"
    placeholder: "판정서 검색..."
    advanced: "상세 검색"
    results: "건"

# en.yml
en:
  disease_case:
    disease_name: "Disease"
    result: "Result"
    year: "Year"
    disease_category: "Category"
    body_part: "Body Part"
    decided_on: "Decision Date"
    link: "Source"
  search:
    title: "Occupational Disease Search"
    placeholder: "Search judgments..."
    advanced: "Advanced Search"
    results: "results"
```

---

## 8. 데이터 로드

seed 사용하지 않고 rake task 파일 생성.
실제 데이터 파일: `comwel_disease_cases.csv`, `comwel_list.csv`
샘플 파일(`comwel-list-sample.csv`, `comwel-case-sample.csv`) 사용하지 않음.

### 마이그레이션 검증 (import 시)

```ruby
# lib/tasks/import_disease_cases.rake
raise "Unknown result: #{value}" unless RESULT_MAP.key?(value)

# 연번 누락/중복 체크
case_nos = rows.map { |r| r["연번"] }
raise "연번 nil 포함" if case_nos.any?(&:blank?)
dups = case_nos.group_by(&:itself).select { |_, v| v.size > 1 }.keys
warn "연번 중복: #{dups}" if dups.any?

# 링크 없는 row 경고 (raise 아님 — 링크 없이도 저장)
rows.each do |r|
  warn "링크 없음: 연번=#{r['연번']}" if r["링크"].blank?
end
```

### Import idempotency

재실행 시 중복 insert 방지 — `find_or_initialize_by` + `upsert_all` 사용:

```ruby
# 단건 (검증 포함)
record = DiseaseCase.find_or_initialize_by(case_no: row["연번"])
record.assign_attributes(attrs)
record.save!

# 대량 (성능 우선)
DiseaseCase.upsert_all(rows, unique_by: :case_no)
```

→ 운영 환경에서 import를 여러 번 실행해도 안전.

### FTS rebuild

대량 import 후 또는 trigger 누락 의심 시 FTS 인덱스 전체 재구성:

```ruby
# lib/tasks/import_disease_cases.rake (import 완료 후 실행)
ActiveRecord::Base.connection.execute(
  "INSERT INTO disease_cases_fts(disease_cases_fts) VALUES('rebuild')"
)
```

별도 rake task로도 제공:

```ruby
namespace :fts do
  desc "FTS5 인덱스 전체 재구성"
  task rebuild: :environment do
    ActiveRecord::Base.connection.execute(
      "INSERT INTO disease_cases_fts(disease_cases_fts) VALUES('rebuild')"
    )
    puts "FTS rebuild 완료"
  end
end
# rails fts:rebuild
```

오류 정책:
- enum 매핑 실패 → `raise` (데이터 정합성 필수)
- 연번 누락 → `raise`
- 연번 중복 → `warn` (로그 후 계속)
- 링크 없음 → `warn` (저장은 진행)

---

---

## 파일 목록

| 파일 | 역할 |
|------|------|
| `db/migrate/YYYYMMDD_create_disease_cases.rb` | 메인 테이블 |
| `db/migrate/YYYYMMDD_create_disease_cases_fts.rb` | FTS5 virtual table + triggers |
| `app/models/disease_case.rb` | 모델 (enum, scope 정의 포함) |
| `app/models/concerns/human_enumerable.rb` | enum i18n 헬퍼 concern |
| `config/locales/models/disease_case/ko.yml` | 한국어 번역 |
| `config/locales/models/disease_case/en.yml` | 영어 번역 |
| `app/services/disease_case_search.rb` | 검색 서비스 (쿼리 전처리 + fallback 포함) |
| `app/controllers/disease_cases_controller.rb` | show |
| `app/controllers/searches_controller.rb` | index(메인), search(상세) |
| `app/views/searches/index.html.erb` | 메인 검색 UI |
| `app/views/searches/search.html.erb` | 상세 검색 UI |
| `app/views/disease_cases/show.html.erb` | 판정서 상세 |
| `lib/tasks/import_disease_cases.rake` | CSV 데이터 로드 (검증 포함) |
| `config/initializers/sqlite_mmap.rb` | mmap pragma 설정 |

---

## 검증

```bash
rails db:create db:migrate
rails server
# http://localhost:3000

rails console
# 기본 체이닝
DiseaseCase.fulltext('"요통"').by_year(2023).order(year: :desc).count
DiseaseCase.fulltext('"뇌경색"').by_result("approved").to_sql

# 검색 서비스 (전처리 포함)
DiseaseCaseSearch.new("요통 치료").results.count
# → '"요통" AND "치료"' 로 변환 후 FTS5 MATCH

DiseaseCaseSearch.new("허리통증이").results.count
# → '"허리통증"' (조사 제거)

DiseaseCaseSearch.new("사무실에서").results.count
# → '"사무실"' ("에서" 복합 조사 제거)

DiseaseCaseSearch.new("zzzunknown").results.count
# → FTS 0건 → fallback: disease_name LIKE '%zzzunknown%'

# 관련도 정렬
DiseaseCase.fulltext('"요통"').order(Arel.sql("bm25(disease_cases_fts)")).limit(10).pluck(:disease_name)

# 날짜 단방향 필터
DiseaseCase.by_date_range("2022-01-01", nil).count   # from만
DiseaseCase.by_date_range(nil, "2023-12-31").count   # to만
```
