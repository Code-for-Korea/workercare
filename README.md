산업재해 프로젝트 산재상담실
---------------------

노동자들이 다치거나 아플 때 근로복지공단으로 요양급여 신청서를 작성하는데 참고하기 위해 근로복지공단 업무상질병 판정서를 검색하고, MCP 프로토콜을 통해 상담 챗봇을 지원합니다.

한국어 전문 검색(full-text)을 구현하며, MCP 엔드포인트를 제공합니다. 로그인 없이 데이터 조회 결과만 제공하기위해 sqlite 데이터베이스를 사용하였고 mysql 또는 postgresql 로 바꾸는 것은 앞으로 검토할 예정입니다.

## 기술 스택

| 항목 | 버전 / 도구 |
|------|------------|
| Ruby | 3.4.7 |
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

## 주요 화면

| 경로 | 설명 |
|------|------|
| `GET /` | 메인 검색 (전문 검색) |
| `GET /search` | 상세 검색 (전문 검색 + 필터) |
| `GET /disease_cases/:id` | 판정서 상세 |

## MCP 서버

MCP 지원 클라이언트에서 아래 URL을 연결하면 업무상질병 판정서 상담 기능을 사용할 수 있습니다.

```
https://..../mcp
```
> 도메인 준비중 입니다

### 제공 Tool

| Tool | 설명 |
|------|------|
| `search_disease_cases` | 판정서 전문 검색 + 통계 집계 |
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

```bash
# 최초 설치
kamal setup

# 배포 (웹 + MCP 서버)
kamal deploy
```

`config/deploy.yml`에 웹 서버(`web`)와 MCP 서버(`mcp`) 두 개의 role이 정의되어 있습니다.

## 관련 문서

- [docs/workercare.plan.md](docs/workercare.plan.md) — 검색 서비스, FTS5, enum, 데이터 설계
- [docs/workercare-mcp.plan.md](docs/workercare-mcp.plan.md) — MCP 컴포넌트 설계, Tool/Prompt 명세

## 라이선스

본 프로젝트는 [Code for Korea](https://codefor.kr) 커뮤니티(산업재해 프로젝트 팀)와 함께 합니다.
