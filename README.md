산업재해 프로젝트 산재상담실
---------------------

노동자들이 다치거나 아플 때 근로복지공단으로 요양급여 신청서를 작성하는데 참고하기 위해 근로복지공단 업무상질병 판정서를 검색하고, MCP 프로토콜을 통해 상담 챗봇을 지원합니다.

한국어 전문 검색(full-text)을 구현하며, MCP 엔드포인트를 제공합니다. 로그인 없이 데이터 조회 결과만 제공하기위해 sqlite 데이터베이스를 사용하였고 mysql 또는 postgresql 로 바꾸는 것은 앞으로 검토할 예정입니다.

## 기술 스택

| 항목 | 버전 / 도구 |
|------|------------|
| Ruby | 3.4.9 |
| Rails | 8.1 |
| 데이터베이스 | SQLite3 (FTS5 전문 검색) |
| MCP 서버 | actionmcp + Falcon |
| CSS | [oat](https://oat.ink/) (importmap CDN) |
| 페이지네이션 | pagy |
| 배포 | Kamal 2.x |

## 설치 및 실행

```bash
# 의존성 설치
bundle install

# 데이터베이스 생성 및 마이그레이션
rails db:create db:migrate

# 개발 서버 실행
bin/dev
```

서버 실행 후 `http://localhost:3000` 으로 접속합니다.

## 데이터 로드

실제 데이터 파일 `comwel_disease_cases.csv`, `comwel_list.csv`를 프로젝트 루트에 위치시킨 뒤 rake task를 실행합니다.

```bash
rails import:disease_cases
```

- `연번`을 식별자(case_no)로 사용합니다.
- 재실행 시 중복 insert 없이 upsert합니다.
- import 완료 후 FTS5 인덱스를 자동으로 rebuild합니다.

FTS5 인덱스를 수동으로 재구성하려면:

```bash
rails fts:rebuild
```

### 직업·신체부위 기반 검색용 데이터 로드

메인 화면(`/`)의 직업·근무조건·신체부위·사망여부·신청서유형 필터와 KSCO 직업분류 연동을 위해, 위 임포트 이후 아래 두 rake task를 **순서대로** 실행합니다 (마이그레이션만으로는 데이터가 채워지지 않습니다).

```bash
rails "import:ksco_codes[wip/ksco-level-4-details.csv]"
rails "import:extracted_disease_cases[wip/extract_disease_cases_details_cerebras-ksco.csv]"
```

- `import:ksco_codes`: 한국표준직업분류(KSCO) 4단계 코드 체계를 `KscoCode`로 임포트합니다.
- `import:extracted_disease_cases`: LLM으로 추출한 직업·근무조건·신체부위·사망여부·신청서유형과 KSCO 매핑(`DiseaseCaseKscoCode`, 유사도 포함)을 기존 `DiseaseCase`에 채우고, `disease_cases_extracted_fts` 인덱스를 rebuild합니다.
- 자세한 설계와 데이터 모델은 [docs/workercare-search.plan.md](docs/workercare-search.plan.md)를 참고합니다.

## 주요 화면

| 경로 | 설명 |
|------|------|
| `GET /` | 메인 검색 (직업·부담 신체 부위·사망여부·신청서유형 필터 + 전문 검색) — 간단한 검색 화면 |
| `GET /search` | 상세 검색 (메인 화면의 모든 필터 + 심의결과·질병분류·신체부위·판정일·근무 형태·업무관련성 평가 필터 + 전문 검색) |
| `GET /disease_cases/:case_no` | 판정서 상세 |

`/search`는 메인 화면(`/`)의 구조화 필터를 전부 포함해서 더 넓게 검색할 수 있습니다. 다만 고용 형태·KSCO 코드는 사용자가 직접 값을 골라 검색할 이유가 적어(고용 형태는 표현이 1,500개 넘게 잘게 쪼개져 있고, KSCO 코드는 숫자 코드) 두 화면 어디에도 입력 필드는 없습니다 — 쿼리스트링이나 MCP 클라이언트로는 계속 필터링할 수 있습니다.

## MCP 서버

MCP 지원 클라이언트에서 아래 URL을 연결하면 업무상질병 판정서 상담 기능을 사용할 수 있습니다.

```
https://..../mcp
```
> 도메인 준비중 입니다

### 제공 Tool

| Tool | 설명 |
|------|------|
| `search_disease_cases` | 판정서 전문 검색(`q`, 선택) + 직업/사망여부/KSCO 코드 등 구조화 필터 + 통계 집계. `q`와 구조화 필터가 전부 비어있으면 에러를 반환합니다(전체 판정서를 검색 결과처럼 반환하지 않음) |
| `compare_approval_factors` | 인정/불인정 사례 패턴 비교 |
| `suggest_evidence` | 필요 증거 자료 제안 (룰 기반) |
| `get_procedure_guide` | 산재 신청 절차 안내 |

### 제공 Prompt

| Prompt | 설명 |
|--------|------|
| `extract_search_keywords` | 자연어 질문에서 검색 키워드 추출 |
| `explain_determination` | 검색 결과를 템플릿 기반으로 구조화 |

MCP 서버는 stateless입니다. 슬롯 관리·LLM 호출·대화 맥락 유지는 클라이언트에서 수행합니다.

### 로컬에서 MCP 서버 실행

```bash
bundle exec falcon serve --bind http://0.0.0.0:3001 --config mcp/config.ru
```

## 배포

[Kamal 2.x](https://kamal-deploy.org/)로 배포합니다.

도커 허브 레지스트리 인증 정보(`KAMAL_REGISTRY_USERNAME`, `KAMAL_REGISTRY_PASSWORD`)가 환경변수에 없으면 `docker login`이 실패합니다. `bin/deploy.sh`가 명령행 프롬프트에서 입력받고 export하여 `bin/kamal`을 실행합니다.

```bash
# Docker Hub 아이디/Access Token을 입력받아 배포 (기본 명령: deploy)
bin/deploy.sh

# 최초 설치
bin/deploy.sh setup

# kamal의 다른 하위 명령도 그대로 전달됩니다 (예: 로그 확인)
bin/deploy.sh logs -r web
```

파라미터를 생략하면 `deploy`를 실행하고, 파라미터는 그대로 `bin/kamal`에 전달합니다.
Access Token(비밀번호)이 비어 있으면 스크립트를 멈춥니다.

환경변수를 이미 별도로(쉘 프로필, 시크릿 매니저 등) 설정하였다면 `bin/kamal setup` / `bin/kamal deploy`를 직접 실행하여도 됩니다.

`config/deploy.yml`에 웹 서버(`web`)와 MCP 서버(`mcp`) 두 개의 role이 정의되어 있습니다.

## 관련 문서

- [docs/workercare.plan.md](docs/workercare.plan.md) — 검색 서비스, FTS5, enum, 데이터 설계
- [docs/workercare-mcp.plan.md](docs/workercare-mcp.plan.md) — MCP 컴포넌트 설계, Tool/Prompt 명세
- [docs/workercare-search.plan.md](docs/workercare-search.plan.md) — 직업·신체부위·사망여부 기반 메인 검색 화면, KSCO 직업분류 연동 설계

## 라이선스

본 프로젝트는 [Code for Korea](https://codefor.kr) 커뮤니티(산업재해 프로젝트 팀)와 함께 합니다.
