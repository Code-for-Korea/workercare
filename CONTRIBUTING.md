# 기여 방법

산재상담실(workercare)에 관심을 가져 주셔서 감사합니다. 이 문서는 프로젝트의 배경, 코드 구조, 데이터가 만들어지는 과정, 개발 환경, 기여 규칙을 한곳에 모았습니다. 서비스를 쓰는 방법은 [USERGUIDE.md](USERGUIDE.md)를 봅니다.

> 확인일: 2026-10-19. 이 문서의 명령과 수치는 이 날짜의 저장소에서 직접 실행하거나 읽어서 확인했습니다. 확인하지 못한 항목은 `[확인 필요]`로 표시하고 맨 끝 "미확인 목록"에 모았습니다.

## 목차

1. [배경과 도입](#1-배경과-도입)
2. [기여할 수 있는 일](#2-기여할-수-있는-일)
3. [개발 환경 시작하기](#3-개발-환경-시작하기)
4. [소스 구조](#4-소스-구조)
5. [데이터는 어떻게 만들어지는가](#5-데이터는-어떻게-만들어지는가)
6. [카카오톡 챗봇을 고칠 때](#6-카카오톡-챗봇을-고칠-때)
7. [브랜치, 커밋, 풀 리퀘스트](#7-브랜치-커밋-풀-리퀘스트)
8. [테스트와 CI](#8-테스트와-ci)
9. [보안과 개인정보 규칙](#9-보안과-개인정보-규칙)
10. [문서 지도](#10-문서-지도)
11. [라이선스](#11-라이선스)
12. [후속 작업과 미확인 목록](#12-후속-작업과-미확인-목록)

---

## 1. 배경과 도입

노동자가 다치거나 아플 때 근로복지공단에 요양급여를 신청합니다. 신청서를 쓰려면 비슷한 업무와 질병이 어떻게 판정됐는지 알아야 하지만, 업무상질병 판정서는 길고 비정형이라 찾아서 비교하기 어렵습니다. 산재상담실은 근로복지공단의 업무상질병 판정서를 검색할 수 있게 하고, 판정서에서 직업·작업 환경·신체 부위 같은 정보를 뽑아 구조화해 더 쉽게 찾도록 돕는 프로젝트입니다. [Code for Korea](https://codefor.kr) 커뮤니티의 산업재해 프로젝트 팀과 함께 만듭니다.

이 서비스는 **개인의 산재 승인 가능성을 예측하지 않습니다.** 비슷한 판정 사례와 그 근거를 보여 줄 뿐이고, 의료·법률 판단을 대신하지 않습니다. 코드와 문서 어디에서든 이 원칙을 지켜 주세요.

### 구성 요소

| 구성 요소 | 하는 일 | 위치 |
|---|---|---|
| 웹 검색 | 메인 검색(`/`), 상세 검색(`/search`), 판정서 상세(`/disease_cases/:case_no`) | `app/controllers/disease_cases_controller.rb`, `app/views/disease_cases/` |
| MCP 서버 | MCP 클라이언트(LLM 앱)가 판정서 검색·비교·절차 안내 도구를 호출 | `app/mcp/`, `mcp/config.ru` |
| 카카오톡 챗봇 스킬 서버 | 카카오 챗봇 관리자센터가 호출하는 `POST /webhooks/kakao`, `POST /webhooks/kakao/jobs` | `app/controllers/webhooks/`, `app/models/chatbot/` |
| 데이터 적재 도구 | CSV를 DB로 가져오는 rake 태스크, 챗봇 엔티티 사전 도구 | `lib/tasks/`, `lib/chatbot/` |

### 기술 스택

Ruby 3.4.9(`.tool-versions`), Rails 8.1, SQLite3와 FTS5 전문 검색, propshaft, importmap, pagy, solid_cache와 solid_queue, actionmcp(MCP), Kamal 2.x 배포입니다. 로그인 없이 조회만 제공하므로 SQLite를 씁니다. MySQL이나 PostgreSQL로의 전환은 검토만 하고 있습니다(README).

---

## 2. 기여할 수 있는 일

| 종류 | 예 |
|---|---|
| 코드 | 검색 정확도·속도 개선, 챗봇 응답 개선, MCP 도구 개선, 버그 수정, 테스트 추가 |
| 데이터 | 구조화 추출의 품질 점검, KSCO 매핑 오류 신고, 비식별이 누락된 판정서 신고 |
| 문서 | 사용자 가이드 보완, 용어 설명, 오래된 문서 정리 |
| 챗봇 | 엔티티 사전(동의어) 보강, 블록·발화 설계, 봇 테스트 시나리오 |

처음이라면 아래 순서가 쉽습니다.

1. [USERGUIDE.md](USERGUIDE.md)로 서비스를 한 번 써 본다.
2. 3장대로 환경을 만들고 `bin/rails test`를 통과시킨다.
3. 작은 문서 오류나 테스트 하나부터 고친다.

큰 변경(검색 구조, DB 스키마, 개인정보 처리 방식)은 먼저 이슈로 의견을 나누고 시작해 주세요.

---

## 3. 개발 환경 시작하기

### 준비물

- Ruby 3.4.9 (`.tool-versions`. asdf나 mise를 쓰면 맞춰 줍니다)
- Bundler, SQLite3(FTS5 포함, 대부분의 최신 배포판에 포함)
- `bin/dev`를 쓰려면 [overmind](https://github.com/DarthSim/overmind)와 tmux

### 설치와 실행

```bash
bin/setup --skip-server   # 의존성 설치(bundle install)와 DB 준비(db:prepare)
bin/dev                   # 웹(3000)과 MCP(62770)를 함께 실행 (overmind 필요)
```

`bin/dev`는 `Procfile.dev`의 두 프로세스를 띄웁니다. `web`은 `http://localhost:3000`, `mcp`는 `62770` 포트입니다. overmind가 없으면 `bin/rails server`만 써도 웹 화면은 확인됩니다. MCP 서버만 따로 띄우려면 아래 명령을 씁니다.

```bash
bundle exec falcon serve --bind http://0.0.0.0:3001 --config mcp/config.ru
```

### 데이터가 없을 때

`bin/setup`이 만든 개발 DB(`storage/development.sqlite3`)는 **비어 있습니다.** 화면은 뜨지만 검색 결과가 없습니다. 원본 판정서 CSV와 추출 CSV는 저장소에 포함되어 있지 않습니다(`/storage/*`와 `/wip`는 `.gitignore`).

- **테스트에는 데이터가 필요 없습니다.** 테스트는 필요한 레코드를 직접 만듭니다.
- 화면과 검색을 직접 보려면 팀에서 데이터 파일을 받아 5장의 순서대로 가져옵니다. 데이터를 받는 방법과 조건은 `[확인 필요]`입니다.
- 급하면 `bin/rails console`에서 `DiseaseCase.create!(case_no: "T-1", disease_name: "회전근개파열", result: "approved", year: 2024, main_reasoning: "...")`처럼 몇 건을 만들어 시험할 수 있습니다. 전문 검색 인덱스는 트리거로 갱신됩니다.

### 자주 막히는 곳

| 증상 | 원인과 대응 |
|---|---|
| `bin/dev`가 `overmind: command not found` | overmind를 설치하거나 `bin/rails server`를 쓴다 |
| 필터 옵션(신체 부위 체크박스)이 데이터를 가져온 뒤에도 그대로 | 옵션을 하루 캐시한다. 바로 반영하려면 `Rails.cache.delete("disease_cases/burden_body_part_token_counts")` |
| 운영 서버에서 `Rails.application.credentials`가 비어 있음 | `config/credentials/*.key`나 `RAILS_MASTER_KEY`가 없다. 키는 저장소에 없다(9장) |

---

## 4. 소스 구조

```
app/
  controllers/
    disease_cases_controller.rb   웹 검색·상세. MAX_SEARCH_RESULTS = 500, 한 쪽 12건
    pages_controller.rb           /about (현재 "소개" 한 줄뿐)
    webhooks/                     카카오 스킬 엔드포인트 (kakao_base, kakao, kakao_jobs)
  models/
    disease_case.rb               판정서 모델, enum(결과·질병분류·신체부위)
    concerns/disease_cases/
      searchable.rb               /search 용 전문 검색 (disease_cases_fts)
      main_searchable.rb          메인 검색·챗봇 공용 (disease_cases_extracted_fts + 구조화 필터)
    ksco_code.rb, disease_case_ksco_code.rb   표준직업분류 코드와 판정서 매핑(유사도 포함)
    chatbot/                      챗봇 전용: 요청 어댑터, 응답 빌더, 검색, 공개용 DTO, 엔티티 사전 읽기
  mcp/
    tools/                        search_disease_cases, compare_approval_factors,
                                  suggest_evidence, get_procedure_guide
    prompts/                      explain_determination, extract_search_keywords, search_disease_case
    resource_templates/           disease-case://{case_no}
  views/, javascript/, assets/    oat CSS, Stimulus(체크박스 묶음·검색 폼 로딩 표시)
config/
  routes.rb                       / , /search , /about , /disease_cases/:case_no , /webhooks/kakao{,/jobs} , /up
  chatbot/entities/*.yml          카카오 엔티티 사전 6종(원본). docs/kakaotalk/entities/*.csv 는 여기서 생성
  evidence_rules.yml              suggest_evidence 도구의 증거 자료 규칙
  locales/                        화면 문구(ko.yml), 모델 속성·enum 라벨, procedure_guides.yml(절차 안내)
  mcp.yml                         MCP 설정 (인증 없음)
db/
  structure.sql                   스키마의 기준. config.active_record.schema_format = :sql
  migrate/                        마이그레이션. FTS 가상 테이블과 트리거 포함
lib/
  tasks/                          import:* , fts:rebuild , chatbot:entities:*
  chatbot/                        엔티티 사전 빌더·탐색기
mcp/config.ru                     MCP를 별도 Rack 앱(Falcon)으로 실행
test/                             controllers, lib, mcp, models (Minitest)
docs/                             기획·설계 문서와 카카오 공식 문서 사본 (10장)
wip/                              로컬 작업 폴더. 저장소에 없음 (5장)
```

**알아 둘 점**

- 스키마의 기준은 `db/structure.sql`입니다. `db/schema.rb`는 추출 컬럼과 KSCO 테이블이 빠져 있어 실제 스키마와 다릅니다. 마이그레이션 뒤에는 `structure.sql`이 갱신되는지 봅니다.
- 판정서 한 건은 한 테이블 `disease_cases`의 한 행입니다. 원문 컬럼(주문, 신청인 주장, 진료기록, 인정 사실, 위원회 판단 등)과 LLM이 추출한 컬럼(직종명, 담당 업무, 부담 신체 부위, 판단 주요 근거 등)이 함께 있습니다.
- 전문 검색 인덱스는 두 개입니다. `disease_cases_fts`(원문 컬럼, `/search`)와 `disease_cases_extracted_fts`(추출 컬럼, 메인 검색과 챗봇). 둘 다 SQLite 트리거로 갱신됩니다. 대량 적재 뒤에는 rake 태스크가 `rebuild`를 실행합니다.
- 메인 검색은 `DiseaseCase.main_search`입니다. 챗봇은 `fts_as_filter: true` 옵션으로 FTS를 필터로만 쓰고 최신순으로 정렬합니다. 웹은 관련도(`bm25`) 순입니다. 카카오 스킬은 5초 안에 응답해야 하기 때문입니다(`docs/kakaotalk/chatbot.md` §6.8).
- 판정 결과는 `approved`(인정), `rejected`(불인정), `partially_approved`(일부인정), `revised_approved`(변경인정) 네 가지입니다.

---

## 5. 데이터는 어떻게 만들어지는가

이 장은 판정서 원본이 DB 레코드가 되기까지의 흐름을 설명합니다. 개념을 먼저 설명하고, 각 단계의 도구와 현재 상태, 마지막에 후속 작업을 정리합니다. 단계 2~4의 스크립트는 `wip/`(로컬 작업 폴더, 약 7.5GB, 저장소에 없음)에 있습니다.

### 5.1 한눈에 보기

```
[1] 원본 수집        근로복지공단 판정서  →  comwel_disease_cases.csv, comwel_list.csv      (수집 방법 [확인 필요])
        │
[2] 입력 분리        본문 4컬럼만 분리    →  disease_cases_details.csv (61,815건)
        │
[3] LLM 구조화       본문에서 20개 항목 추출 → extract_disease_cases_details_cerebras.csv
        │
[4] KSCO 매핑        직종명·업무 임베딩으로 표준직업분류 후보 5개 → ...-ksco.csv (55,377건)
        │
[5] DB 적재(rake)    import:disease_cases → import:ksco_codes → import:extracted_disease_cases
        │
[6] 검증과 서비스    FTS 인덱스, 필터, 챗봇·MCP가 같은 DB를 읽음
```

현재까지 확인한 건수는 다음과 같습니다. 원본 판정서 61,815건, LLM 추출 결과 55,377건(**6,438건은 추출 결과가 없습니다**), KSCO 세분류 코드 495개입니다.

### 5.2 단계 1. 원본 수집

- 원본은 근로복지공단 업무상질병 판정서입니다. 챗봇 목록의 상세 링크는 공단의 판정서 사이트(`https://jilbyungcase.comwel.or.kr/service/dataView?id=<연번>`)를 가리킵니다.
- 두 개의 CSV로 보관합니다. `comwel_disease_cases.csv`는 판정서 본문(연번, 신청질병, 심의결과, 심의연도, 질병분류, 신체부위, 주문, 청구 취지, 신청 내용, 신청인 주장, 진료기록 및 의학적 소견, 인정 사실, 관계 법령, 위원회 판단 및 결론, 판정일)이고, `comwel_list.csv`는 목록(연번, 링크 등)입니다. `연번`이 식별자(`case_no`)입니다.
- 판정서에는 원래부터 개인정보를 기호로 대체한 비식별 처리가 되어 있다고 기획서에 기록되어 있습니다(`docs/kakaotalk/project-plan.md` §9). **비식별은 적재 단계의 책임**이며, 새 데이터도 같은 기준을 만족해야 합니다.
- **수집 방법, 공단 사이트의 이용 조건, 재배포 가능 여부는 저장소에 기록이 없습니다.** `[확인 필요]`

### 5.3 단계 2. 입력 분리

LLM 추출에는 본문 중 판단에 쓰이는 세 컬럼만 넣습니다. `disease_cases_details.csv`(헤더 `case_no`, `medical_records`, `recognized_facts`, `committee_decision`, 61,815행)가 입력 파일입니다.

### 5.4 단계 3. LLM 구조화 추출

판정서 본문에서 아래 20개 항목을 뽑습니다. 한 사례의 직종과 작업 환경, 신체 부담, 판정을 구조화해서 검색 필터와 챗봇 응답에 씁니다.

| 묶음 | 항목 |
|---|---|
| 직종 | 직종명, 담당 업무, 고용 형태, 근무 형태, 현 직종 총 종사기간, 1주·1일 평균 근무시간 |
| 신체 부담 | 부담 신체 부위, 주요 부적절한 자세, 중량물 취급 여부, 취급 물품 최대 무게, 1일 취급 총 누적 중량, 기타 유해요인 노출 |
| 판단 | 업무관련성 평가, 업무부담 가중요인 노출, 최종 산재 인정 여부, 판단 주요 근거 |
| 기타 | 사망 여부, 신청서 종류 |

- **최종 사용한 방식:** Cerebras Inference API의 `gemma-4-31b` 모델로 25건 안팎을 한 번에 보내는 동적 배치(`MAX_BATCH_SIZE`, `MAX_PROMPT_CHARS`)입니다. 실패하면 배치를 줄여 다시 보내고, 재개와 오류·토큰 로그를 남깁니다(`wip/extract_cerebras.rb`와 `wip/cerebras_prompts.rb`, 설계는 `wip/wip-cerebras.md`). 결과는 `extract_disease_cases_details_cerebras.csv`입니다.
- **시도했지만 최종 경로가 아닌 방식:** 로컬 Ollama(`extract_disease_cases_detail*.rb`), NotebookLM CLI(`extract_job_via_nlm.rb`), Upstage Solar(`extract_solar_*.rb`), K-EXAONE 데모 웹 자동화(`exaone_*.rb`, 데모 종료 예정일이 있어 시간제한 작업), chat.hongik.ai 웹챗 제안서, OpenCode 헤드리스 파이프라인(`wip/wip-alpha-plan.md`, 중단됨, 20건 보존). 모델별 비교는 `wip/compare*.txt`, `wip/analyze_compare.rb`, `wip/verify_extraction.rb`에 있습니다.
- **추가 의료 항목**(성별, 연령, 신체계측, 영상 소견, 건강검진 이력 등)을 뽑는 별도 계획과 스크립트(`extract_cerebras_medical.rb`, `wip/wip-solar-medical-plan.md`)가 있지만, **현재 `import` 태스크는 이 항목들을 읽지 않습니다.** 서비스에 쓰이지 않습니다.
- **외부로 나간 데이터:** 추출 단계에서 판정서 본문이 외부 LLM 서비스(Cerebras API 등)로 전송됩니다. 판정서는 비식별 처리된 상태이지만, 다른 외부 서비스로 판정서를 보내는 작업은 팀에서 먼저 합의하세요. `wip/hongik-work-extraction-proposal.md`는 "민감한 판정서 데이터를 외부 서비스로 전송하는 실행은 별도 승인 후"라고 전제를 적어 두었습니다.
- **알려진 철자 오류:** 최종 CSV의 헤더는 `업묵부담_가중요인_노출`(업**묵**)입니다. 추출 계획은 `업무부담_가중요인_노출`로 정정했지만 최종 파일과 `import:extracted_disease_cases` 태스크는 지금도 `업묵부담…` 철자를 읽습니다. **두 곳을 같이 바꾸지 않으면 이 컬럼이 비어서 들어갑니다.**

### 5.5 단계 4. KSCO(한국표준직업분류) 매핑

직종명만으로는 같은 직업이 여러 표현으로 갈립니다(예: 조리원, 조리사, 주방 보조). 그래서 판정서마다 한국표준직업분류 세분류(4자리) 후보를 붙여 직업 단위로 묶어 찾을 수 있게 합니다.

1. **분류표 구조화:** 제8차 한국표준직업분류(통계청고시 제2024-328호, 시행 2025.1.1.)의 PDF(`wip/ksco.pdf`, 129쪽부터)에서 세분류 4자리 코드별로 **직업예시**와 **직업제외**를 뽑아 `ksco-level-4-details.csv`(495개 코드)를 만듭니다(`wip/extract_ksco_level4_details.rb`, 계획은 `wip/wip-ksco-level-4-details-plan.md`).
2. **임베딩:** Cloudflare Workers AI의 `@cf/google/embeddinggemma-300m`(768차원)으로 판정서의 `직종명`과 `담당_업무`, KSCO의 `세분류`와 `직업예시`를 각각 벡터로 만듭니다(`wip/embed_disease_cases_cf.rb`, `wip/embed_ksco_cf.rb`, 환경변수 `CF_ACCOUNT_ID`, `CF_API_TOKEN`).
3. **유사도 매칭:** 판정서의 두 벡터를 평균해 정규화하고, KSCO 항목마다 `세분류`와 `직업예시` 벡터와의 내적 중 큰 값을 유사도로 삼아 **상위 5개**를 뽑습니다(`wip/ksco_disease_cases.rb`). 결과는 `ksco_codes_json`(코드, 이름, 유사도)에 담겨 `extract_disease_cases_details_cerebras-ksco.csv`가 됩니다.
4. 이 매핑은 **자동 추정**입니다. 유사도 낮은 후보가 들어 있을 수 있어, 사람이 검증하는 단계는 아직 없습니다.

참고: 이 스크립트는 진행률 계산에 `55377`이 코드에 고정되어 있습니다. 입력이 달라지면 고쳐야 합니다.

### 5.6 단계 5. DB 적재(rake)

**순서를 지켜야 합니다.** 앞 단계가 만든 레코드를 뒤 단계가 갱신합니다. 파일 경로는 로컬 파일의 위치를 쓰세요.

```bash
# 1) 판정서 본문과 링크
bin/rails "import:disease_cases[comwel_disease_cases.csv,comwel_list.csv]"

# 2) 표준직업분류 코드 체계
bin/rails "import:ksco_codes[ksco-level-4-details.csv]"

# 3) 추출 컬럼과 KSCO 매핑
bin/rails "import:extracted_disease_cases[extract_disease_cases_details_cerebras-ksco.csv]"

# (필요하면) 원문 전문 검색 인덱스만 다시 만들기
bin/rails fts:rebuild
```

- 1)은 `case_no`로 upsert하고 끝에서 `disease_cases_fts`를 rebuild합니다. 알 수 없는 심의결과가 있으면 그 행에서 멈춥니다.
- 3)은 추출 컬럼을 덮어쓰고, 판정 결과가 원본과 다르면 **덮어쓰지 않고 경고만** 냅니다. KSCO 매핑은 CSV의 목록을 "전체 목표"로 보고 **목록에 없는 기존 매핑을 지웁니다.** 단, `ksco_codes_json`이 비었거나 파싱에 실패한 행은 기존 매핑을 건드리지 않습니다. 끝에서 `disease_cases_extracted_fts`를 rebuild합니다.
- 3)에서 KSCO 코드가 없으면 경고만 내고 건너뜁니다. 먼저 2)를 실행했는지 확인하세요.
- 필터 옵션 캐시가 있어 적재 뒤 화면 반영은 최대 하루 걸립니다(3장).

### 5.7 단계 6. 검증

적재 뒤에 아래를 확인합니다.

- 건수: `DiseaseCase.count`가 61,815, 직종명이 있는 건수가 추출 결과와 같은지.
- 경고 로그: `result 불일치`, `KSCO 코드 없음`, `판정서 없음`.
- 표본 점검: 사례 몇 건을 원본 판정서와 대조(판정 결과, 직종, 신체 부위). 특히 추출 컬럼과 비식별 누락.
- 챗봇용 엔티티는 DB 값을 기준으로 만듭니다(6장).

### 5.8 후속 작업 (보류 중)

다음은 이 문서에서 다루지 않고 **후속 작업으로 남겼습니다.** 구조와 데이터 파이프라인을 `docs/contributing/`로 나눠 쓰는 일도 포함합니다.

1. **스크립트를 저장소로 옮기기.** 지금은 추출·임베딩·매핑 스크립트가 `.gitignore`된 `wip/`에만 있어 재현할 수 없습니다. 재현 가능한 최소 경로(Cerebras 추출 → 임베딩 → 매핑)를 골라 `lib/`나 `script/`로 옮기고, 비밀값은 환경변수로 받습니다. `wip/download-olap-data.txt` 같은 쿠키가 든 메모는 옮기지 않습니다.
2. **빠진 6,438건**의 원인을 확인하고 다시 추출합니다.
3. **헤더 철자(`업묵부담…`)**를 추출 스키마, CSV, import 태스크에서 함께 정정합니다.
4. **KSCO 매핑 품질 검증.** 표본 검수와 유사도 하한선 정하기.
5. **최신 판정서 갱신 주기**와 재적재 절차(증분 import).
6. **비식별 점검 도구.** 이름·주소 같은 서술형 개인정보는 `PIIMasking`이 걸러내지 못합니다(9장).
7. **원본 수집 방법과 이용 조건 문서화** `[확인 필요]`.

---

## 6. 카카오톡 챗봇을 고칠 때

챗봇은 두 부분입니다. **Rails 스킬 서버**(이 저장소)와 **카카오 챗봇 관리자센터의 설정**(블록, 발화, 엔티티, 컨텍스트)입니다. 관리자센터 설정은 저장소 밖(카카오 서비스)에 있고, 작업 방법과 결정 이력, 봇 테스트 시나리오가 [docs/kakaotalk/chatbot.md](docs/kakaotalk/chatbot.md)에 있습니다. 여기서는 핵심 규칙만 적습니다.

### 스킬 서버

- 엔드포인트는 `POST /webhooks/kakao`(사례 검색)와 `POST /webhooks/kakao/jobs`(직종 검색)입니다. 요청 헤더 `X-Skill-Token`이 `Rails.application.credentials.kakao.skill_token`(또는 환경변수 `KAKAO_SKILL_TOKEN`)과 같아야 합니다. 값은 저장소에 없습니다.
- 항상 HTTP 200과 유효한 응답 본문을 돌려줍니다. 오류와 결과 없음도 안내 문구 응답입니다. 카카오의 응답 제한 시간은 **5초 고정**입니다.
- 사용자의 발화 원문을 저장하거나 로그에 남기지 않습니다(직종 검색의 선택 경로 제외). 로그에는 건수와 처리 시간만 기록합니다. 9장을 보세요.
- 카카오 응답 규격(`outputs` 3개, 바로연결 10개, `listCard` 제목·설명 글자 수 등)은 `Chatbot::KakaoResponseBuilder`가 지키고 테스트로 고정되어 있습니다.

### 엔티티 사전

카카오 엔티티 CSV는 손으로 만들지 않고 사전(YAML)에서 만듭니다.

```bash
bin/rails chatbot:entities:check                   # 구조와 엔티티 사이 중복 검증
bin/rails chatbot:entities:discover ENTITY=job_name LIMIT=30   # 사전이 덮지 못한 용어 찾기
bin/rails chatbot:entities:build                   # docs/kakaotalk/entities/*.csv 생성
```

- 원본은 `config/chatbot/entities/*.yml`이고 `docs/kakaotalk/entities/*.csv`는 생성물입니다. CSV를 직접 고치지 말고 사전을 고쳐 다시 만듭니다.
- 같은 동의어를 서로 다른 엔티티에 넣으면 카카오의 인식이 나빠집니다. `check`가 이 중복을 막습니다.

### 관리자센터에서 지킬 규칙

- **발화는 모든 블록에서 서로 달라야 합니다.** 같은 발화를 다른 블록에 넣으면 입력 컨텍스트가 달라도 중복 오류가 납니다. 건너뛰기처럼 여러 단계에 같은 뜻이 필요하면 단계 이름을 붙인 다른 문장을 씁니다.
- 파라미터 값 칸의 `$이름`은 엔티티가 아니라 **파라미터 이름**을 가리킵니다.
- 카카오는 사용자가 쓴 동의어가 아니라 **대표 엔트리**를 보냅니다. 서버는 대표 엔트리를 사전의 `db` 목록으로 넓혀 검색합니다.

---

## 7. 브랜치, 커밋, 풀 리퀘스트

### 브랜치

기능 `feat/…`, 정리·문서 `chore/…`, 버그 `fix/…`를 씁니다. 기본 브랜치는 `main`입니다. 예: `feat/kakaotalk_chatbot`, `chore/user_guide`, `fix/mcp-stale-tests`.

### 커밋

- **제목은 한국어 명령형 `~합니다`** 로 한 줄에 씁니다. 예: `검색 로그에서 질의 원문을 제거합니다`. 필요하면 빈 줄 뒤에 이유를 적습니다. "무엇을"보다 "왜"를 적습니다.
- 한 커밋은 한 가지 일만 합니다. 코드, 문서, 데이터 도구는 따로 커밋합니다.
- **커밋할 파일을 경로로 지정하세요.** 이 저장소는 파일이 미리 스테이지되는 일이 있어 `git commit`만 하면 의도하지 않은 파일이 섞입니다.

  ```bash
  git commit -m "제목합니다" -- path/one.rb path/two.rb
  ```
- 비밀값, 개인정보, 원본 데이터, `wip/`의 파일은 커밋하지 않습니다.

### 풀 리퀘스트

1. `main`에서 브랜치를 만들어 작업합니다.
2. 아래 8장의 검사를 통과시키거나, 통과하지 못하는 항목이 이미 있던 것인지 적습니다.
3. 설명에 **무엇을, 왜, 어떻게 확인했는지**를 적습니다. 검색 결과나 챗봇 응답이 바뀌면 전후 예시를 첨부합니다.
4. 한 PR에는 하나의 주제만 담습니다.

---

## 8. 테스트와 CI

### 실행

```bash
bin/rails test                      # 전체 테스트 (2026-10-19 기준 284개 통과)
bin/rails test test/models/chatbot  # 일부만
bin/rubocop                         # 스타일 (rubocop-rails-omakase)
bin/brakeman --quiet --no-pager     # 정적 보안 분석
bin/bundler-audit                   # gem 취약점
bin/importmap audit                 # JS 패키지 취약점
bin/ci                              # 위 단계를 config/ci.rb 순서대로 실행
```

테스트는 Minitest이고 `test/controllers`, `test/lib`, `test/mcp`, `test/models`에 있습니다. 새 코드에는 테스트를 같이 추가합니다. 테스트 DB는 `storage/test.sqlite3`이며 개발 DB와 별개입니다.

### 현재 CI 상태 (2026-10-19)

**`bin/ci`는 지금 통과하지 못합니다.** 새 변경이 이 상태를 더 나쁘게 만들지 않도록 확인해 주세요.

| 단계 | 상태 | 내용 |
|---|---|---|
| `bin/rails test` | 통과 | 284개 |
| `bin/rubocop` | 실패 | 약 230건. 대부분 `wip/`의 스크립트가 검사 대상에 포함되어서 나옴. `wip/`를 제외하면 8개 파일에 57건(`Layout/SpaceInsideArrayLiteralBrackets` 56건, `Layout/EndAlignment` 1건): `app/mcp/tools/{compare_approval_factors,suggest_evidence}_tool.rb`, `lib/tasks/import_*.rake`, `test/mcp/tools/*`, `config/application.rb` |
| `bin/brakeman` | 실패(경고 8건) | `wip/` 파일 2건과 `app/`·`lib/`의 Weak 신뢰도 경고. `app/views/disease_cases/*/_disease_case.html.erb`, `app/models/chatbot/job_candidates.rb`, `app/models/concerns/disease_cases/main_searchable.rb`, `lib/chatbot/entity_builder.rb`. 열거된 SQL 조각은 값이 아닌 고정 문자열에서 나온 것이라 오탐일 가능성이 있으나 검토가 필요합니다. |
| `bin/bundler-audit` | 실패 | `puma` 7.2.0(→ 7.2.1 이상), `sqlite3` 2.9.2(→ 2.9.6 이상), `msgpack` 1.8.0(→ 1.8.2 이상) |
| `bin/importmap audit` | 통과 | 취약 패키지 없음 |

- **GitHub Actions는 꺼져 있습니다.** `.github/workflows/ci.yml_`과 `.github/dependabot.yml_`는 확장자 끝에 `_`가 붙어 비활성입니다. 켜기 전에 위 실패를 정리해야 합니다. 정리 작업(rubocop 설정에서 `wip/` 제외, gem 업데이트, brakeman 경고 검토)은 후속 작업입니다.
- rubocop은 `wip/`를 제외하고 확인하려면 `bin/rubocop app lib test config db bin mcp`를 씁니다.

---

## 9. 보안과 개인정보 규칙

이 프로젝트의 데이터는 실제 사람의 질병과 일터 이야기입니다. 아래 규칙은 코드와 문서, 운영 모두에 적용됩니다.

1. **비밀값을 커밋하지 않습니다.** `config/master.key`, `config/credentials/*.key`, `.env*`, API 키, 쿠키가 든 메모는 저장소에 올리지 않습니다(`.gitignore`가 일부를 막지만 확인은 사람이 합니다). 챗봇 스킬 토큰은 credentials(`kakao.skill_token`)나 환경변수로 관리합니다. 배포용 키는 `.kamal/secrets`가 읽습니다.
2. **판정서는 비식별 처리된 데이터로 취급하되 완전하다고 믿지 않습니다.** `PIIMasking`은 주민번호·전화번호·이메일·계좌번호의 **형태**만 가리는 보조 장치입니다. 이름이나 주소 같은 서술형 개인정보는 걸러내지 못합니다. 누락을 발견하면 해당 `case_no`를 팀에 신고해 DB에서 수정하거나 삭제하게 합니다.
3. **사용자 발화 원문을 저장하거나 로그에 남기지 않습니다.** 챗봇 경로는 이미 이 원칙을 지킵니다. 다만 Rails 기본 `Parameters:` 로그와 웹 검색의 `params[:q]` 로그에는 아직 원문이 남습니다. **출시 전에 `filter_parameters` 정리가 필요합니다**(`docs/kakaotalk/chatbot.md` §10). 테스트에 실제 개인정보를 넣지 마세요.
4. **응답에는 허용 필드 목록만 담습니다.** 챗봇 응답은 `Chatbot::PublicCase`의 고정 필드로만 직렬화합니다. 새 필드를 추가하면 비식별 상태를 먼저 확인합니다.
5. **외부 서비스로 판정서를 보내기 전에 합의합니다.** 외부 LLM·임베딩 서비스로 본문을 보내는 작업은 팀에서 먼저 정합니다(5.4).
6. **승인 가능성을 예측하지 않습니다.** "당신의 사건은 인정됩니다/불인정됩니다" 같은 응답을 만들지 않습니다. 제도 안내는 공식 출처와 확인일을 함께 적습니다(`config/locales/procedure_guides.yml`의 `source`, `last_updated`).
7. **보안 취약점은 공개 이슈로 올리지 않습니다.** 팀에 직접 알려 주세요. `[연락 방법 확인 필요]`

---

## 10. 문서 지도

| 문서 | 용도 | 상태 |
|---|---|---|
| [README.md](README.md) | 프로젝트 소개, 실행, 배포 | 현재 |
| [USERGUIDE.md](USERGUIDE.md) | 노동자·상담 활동가를 위한 사용 안내(웹, 챗봇, MCP) | 현재 |
| [docs/workercare.plan.md](docs/workercare.plan.md) | 검색 서비스, FTS5, enum, 초기 데이터 설계 | 설계(일부 구현과 다름) |
| [docs/workercare-search.plan.md](docs/workercare-search.plan.md) | 직업·신체 부위·사망 여부 검색, KSCO 연동 설계 | 설계(구현됨, 세부는 코드 우선) |
| [docs/workercare-mcp.plan.md](docs/workercare-mcp.plan.md) | MCP 도구·프롬프트 설계와 사용자 시나리오 | 설계 |
| [docs/server-setup-ubuntu.md](docs/server-setup-ubuntu.md) | Ubuntu 서버 기본 설치 | 현재 |
| [docs/kakaotalk/project-plan.md](docs/kakaotalk/project-plan.md) | 챗봇 기획서: 배경, 목표, 공개·안전 기준 | 기획 |
| [docs/kakaotalk/development-plan.md](docs/kakaotalk/development-plan.md) | 챗봇 개발 계획 | 계획(진행은 `chatbot.md`) |
| [docs/kakaotalk/chatbot.md](docs/kakaotalk/chatbot.md) | **챗봇 작업 기록과 관리자센터 가이드**, 봇 테스트 시나리오 | 현재, 가장 최신 |
| `docs/kakaotalk/entities/*.csv` | 카카오 엔티티 업로드 파일(사전에서 생성) | 생성물 |
| `docs/kakaotalk/chatbot/*`, `docs/kakaotalk/knowledge/*` | 카카오 공식 문서 사본 | 외부 자료 |

문서끼리 내용이 다르면 **코드가 기준**입니다. 설계 문서는 구현 전의 계획이라 실제와 다를 수 있습니다.

---

## 11. 라이선스

**[라이선스 문구 대기]**

코드의 라이선스와 판정서 데이터의 이용 조건은 아직 이 저장소에 적혀 있지 않습니다(`LICENSE` 파일 없음, README의 라이선스 절은 커뮤니티 소개뿐). 정해지면 이 절에 코드와 데이터를 나눠 적습니다.

---

## 12. 후속 작업과 미확인 목록

### 후속 작업

- 구조(4장)와 데이터 파이프라인(5장)을 `docs/contributing/`로 나눠 더 자세히 쓰기
- `bin/ci` 정리(8장): rubocop의 `wip/` 제외, 취약 gem 업데이트, brakeman 경고 검토, GitHub Actions 활성화
- 파이프라인 스크립트의 저장소 이전(5.8)
- 출시 전 로깅 정리(`filter_parameters`, 웹 검색의 `params[:q]`)

### 미확인 목록

| 항목 | 이유 |
|---|---|
| 판정서 원본의 수집 방법과 공단 사이트 이용 조건 | 저장소에 기록 없음 |
| 코드 라이선스, 데이터 이용 조건 | 문구 대기 |
| 개발용 데이터 파일을 받는 방법 | 저장소에 기록 없음 |
| 추출 결과 55,377건과 전체 61,815건의 차이 원인 | 확인하지 못함 |
| 개발 DB에 KSCO 코드 3개와 매핑 0건만 있는 이유 | 가져오기를 하지 않은 환경으로 보이나 확인하지 못함 |
| 취약점 신고 연락 방법 | 저장소에 기록 없음 |
| `.github/` CI를 켜지 않은 이유 | 확인하지 못함 |
