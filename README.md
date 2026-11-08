산업재해 프로젝트 산재상담실
---------------------

노동자들이 다치거나 아플 때 근로복지공단으로 요양급여 신청서를 작성하는데 참고하기 위해 근로복지공단 업무상질병 판정서를 검색하고, 카카오톡 챗봇과 마크다운 응답(LLM·스크립트용)을 제공합니다.

한국어 전문 검색(full-text)을 구현하며, 검색·검색결과·상세를 마크다운으로도 제공합니다. 로그인 없이 데이터 조회 결과만 제공하기위해 sqlite 데이터베이스를 사용하였고 mysql 또는 postgresql 로 바꾸는 것은 앞으로 검토할 예정입니다.

## 기술 스택

| 항목 | 버전 / 도구 |
|------|------------|
| Ruby | 3.4.9 |
| Rails | 8.1 |
| 데이터베이스 | SQLite3 (FTS5 전문 검색) |
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
| `GET /` | 메인 검색 (직업·부담 신체 부위·신청서 종류·고용 형태·근무 형태·업무관련성·사망 여부 필터 + 전문 검색) — 간단한 검색 화면 |
| `GET /search` | 상세 검색 (메인 화면의 모든 필터 + 심의결과·심의연도·질병분류·신체부위·판정일 필터 + 판정서 본문 전문 검색) |
| `GET /disease_cases/:case_no` | 판정서 상세 |
| `GET /self-care-form` | **산재알아보기**: 단계별로 고르면 비슷한 판정 사례를 보여 주는 화면(`docs/self-care-form.md`) |
| `GET /apply-guide` | 산재 신청 방법 안내(`.md`도 제공) |

두 화면은 같은 구조화 필터(신청서 종류·고용 형태·근무 형태·업무관련성·사망 여부)를 씁니다. 이 값들은 표기 흔들림을 정리한 정규화 값입니다(`docs/disease-cases-normalization.md`). 신청서 종류는 체크박스(여러 개를 고르면 하나라도 포함된 사례), 고용 형태·근무 형태는 범주 목록에서 고릅니다. KSCO 코드는 숫자 코드라 입력 필드가 없고, 쿼리스트링으로 필터링할 수 있습니다.

## 마크다운 응답 (LLM·스크립트용)

같은 주소에 `.md`를 붙이거나 `Accept: text/markdown`을 보내면 마크다운으로 응답합니다. MCP 서버는 제거했습니다.

| 주소 | 내용 |
|---|---|
| `/index.md` (또는 `/`) | 간단한 검색 결과 |
| `/search.md` | 상세 검색 결과 |
| `/disease_cases/:case_no.md` | 판정서 상세 |

```bash
curl 'https://.../search.md?q=손목&application_type[]=요양급여'
curl -H 'Accept: text/markdown' 'https://.../disease_cases/<연번>'
```

파라미터, 헤더(`Vary: Accept`, `Link`), 이스케이프·비식별 규칙은 [docs/markdown-responses.md](docs/markdown-responses.md)에 있습니다.

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

`config/deploy.yml`에는 웹 서버(`web`) role 하나가 정의되어 있습니다. MCP를 제거했으므로 이전 배포에서 남은 `mcp` 컨테이너는 `bin/kamal app stop --roles=mcp`로 정리합니다.

## 관련 문서

- [USERGUIDE.md](USERGUIDE.md) — 노동자·상담 활동가를 위한 사용 안내 (웹, 카카오톡 챗봇, 마크다운 응답)
- [CONTRIBUTING.md](CONTRIBUTING.md) — 기여 방법: 배경, 개발 환경, 소스 구조, 데이터 파이프라인, 커밋·CI 규칙
- [docs/kakaotalk/chatbot.md](docs/kakaotalk/chatbot.md) — 카카오톡 챗봇 작업 기록과 관리자센터 가이드
- [docs/workercare.plan.md](docs/workercare.plan.md) — 검색 서비스, FTS5, enum, 데이터 설계
- [docs/markdown-responses.md](docs/markdown-responses.md) — 검색·상세 마크다운 응답(주소, 헤더, 파라미터)
- [docs/workercare-mcp.plan.md](docs/workercare-mcp.plan.md) — (폐기) MCP 설계 이력
- [docs/workercare-search.plan.md](docs/workercare-search.plan.md) — 직업·신체부위·사망여부 기반 메인 검색 화면, KSCO 직업분류 연동 설계

## 라이선스

**[라이선스 문구 대기]** 코드의 라이선스와 판정서 데이터의 이용 조건은 정해지는 대로 이곳과 [CONTRIBUTING.md](CONTRIBUTING.md#11-라이선스)에 적습니다.

본 프로젝트는 [Code for Korea](https://codefor.kr) 커뮤니티(산업재해 프로젝트 팀)와 함께 합니다.
