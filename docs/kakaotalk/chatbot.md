# 카카오톡 챗봇 작업 문서

- 작성일: 2026-10-17
- 브랜치: `feat/kakaotalk_chatbot`
- 연계 문서: [`project-plan.md`](project-plan.md)(기획), [`development-plan.md`](development-plan.md)(개발 계획), [`chatbot/`](chatbot/)(카카오 챗봇 관리자센터 참고 자료)
- 이 문서의 역할: 기획·개발 계획을 **작업 단위**로 나누고, 각 작업의 진행 상태와 실제 코드 계약을 기록한다. 계획과 코드가 다르면 이 문서와 코드를 기준으로 계획서를 고친다.

## 목차

1. [작업 현황 요약](#1-작업-현황-요약)
2. [구현 완료 내역](#2-구현-완료-내역)
3. [스킬 서버 계약](#3-스킬-서버-계약)
4. [인증과 환경변수](#4-인증과-환경변수)
5. [카카오 관리자센터 설정](#5-카카오-관리자센터-설정)
6. [엔티티·발화·블록 작업](#6-엔티티발화블록-작업)
7. [로깅·개인정보 작업](#7-로깅개인정보-작업)
8. [배포 작업](#8-배포-작업)
9. [테스트·검증 작업](#9-테스트검증-작업)
10. [남은 작업 목록](#10-남은-작업-목록)
11. [결정이 필요한 사항](#11-결정이-필요한-사항)

---

## 1. 작업 현황 요약

| 영역 | 상태 | 비고 |
|---|---|---|
| 선행 코드 작업 — `show` 404 | 완료 | `50979a6` |
| 선행 코드 작업 — `disease_name`·`result` 필터 | 완료 | `c37b099` |
| 선행 코드 작업 — 검색 로그 `q` 원문 제거 | **보류** | 개발 테스트 기간에는 유지. 출시 전 처리(§7) |
| 스킬 서버 뼈대(`POST /webhooks/kakao`) | 완료 | `2103f86`. 사례 검색만 구현 |
| 인증 방식 확정 | 설계 완료, **서버 설정 미완** | credentials 방식 권장(§4) |
| 카카오 관리자센터 스킬 등록·블록 연결 | 미착수 | §5 |
| 엔티티·발화·블록 구성 | 미착수 | §6 |
| 검색 세션(`CASE_REFINE`) | 미착수 | 현재는 버튼 `extra`로 조건을 이어받는 방식 |
| 산재 신청 절차 안내(`GUIDE`) | 미착수 | 공식 출처·확인일 필요 |
| 평가 세트·배포 | 미착수 | §8, §9 |

전체 테스트는 87개이며 모두 통과한 상태다(2026-10-17 기준). 이 문서의 "완료"는 로컬 테스트 기준이며, 카카오 관리자센터와 연동한 실제 호출은 아직 확인하지 않았다.

---

## 2. 구현 완료 내역

### 2.1 `show` 404 (`50979a6`)

- `DiseaseCasesController#show`가 `find_by!`를 쓴다. 없는 `case_no`는 404를 반환한다.
- 테스트: 존재하는 사례 표시, 없는 `case_no` 404.

### 2.2 검색 필터 추가 (`c37b099`)

- `DiseaseCase.apply_main_filters`에 추가:
  - `disease_name`: `LIKE` 부분 일치. `main_search`의 전문 검색(FTS) 대상 컬럼에 질병명이 없어 `q`로는 찾을 수 없기 때문이다.
  - `result`: enum 값 일치(`approved`, `rejected`, `partially_approved`, `revised_approved`).
- `main_search_params` 허용 목록에 두 값을 추가했다. 웹 검색 화면에는 입력을 노출하지 않았다.
- **기존 버그 수정:** `q`와 `job_name`을 함께 쓰면 `ambiguous column name: job_name` SQL 오류가 났다. FTS 가상 테이블에도 같은 컬럼이 있기 때문이다. 필터의 컬럼을 `disease_cases.` 접두어로 한정해 해결했다.
- 테스트: 질병명 부분 일치, enum 4종 각각, 질병·직종·`q`·결과 동시 적용(AND), FTS 폴백 시 필터 유지.

### 2.3 스킬 서버 뼈대 (`2103f86`)

| 구성 요소 | 위치 | 역할 |
|---|---|---|
| 라우트 | `config/routes.rb` | `POST /webhooks/kakao` |
| `Webhooks::KakaoController` | `app/controllers/webhooks/kakao_controller.rb` | 인증, 요청 파싱, 응답, 로깅 |
| `Chatbot::KakaoRequestAdapter` | `app/models/chatbot/` | 카카오 payload → 내부 검색 조건 |
| `Chatbot::CaseSearch` | `app/models/chatbot/` | `main_search` 호출, 페이지·건수 계산 |
| `Chatbot::PublicCase` | `app/models/chatbot/` | 공개 DTO(허용 필드만) |
| `Chatbot::KakaoResponseBuilder` | `app/models/chatbot/` | 카카오 `version: "2.0"` 응답 생성 |

설계 결정과 이유:

- **`ActionController::API` 상속.** 카카오 요청에는 CSRF 토큰이 없다. `ActionController::Base`를 쓰면 운영에서 422가 난다. 테스트 환경은 CSRF 보호가 꺼져 있어 테스트로는 놓치기 쉬우므로, 보호를 켠 상태로 요청하는 테스트를 따로 두었다.
- **요청 본문은 `raw_post`를 직접 파싱.** 카카오 payload의 최상위 `action` 키가 Rails 라우팅의 `params[:action]`과 충돌한다.
- **항상 HTTP 200과 유효한 응답 본문.** 결과 없음, 잘못된 입력, 예외 모두 안내 응답으로 처리한다. 카카오 응답 타임아웃(5초)은 고정이다.
- **`textCard` 캐로셀 사용.** `basicCard`는 썸네일이 필수다.
- **바로연결은 `action: "message"`만 사용.** 실제 블록 ID가 아직 없다. 바로연결은 엔티티를 다시 추출하지 않으므로 조건을 `extra`에 실어 `clientExtra`로 이어받는다.

---

## 3. 스킬 서버 계약

### 3.1 요청에서 읽는 값

| 값 | 위치 | 용도 |
|---|---|---|
| `disease_name` | `action.params` | 질병명 필터 |
| `job_name` | `action.params` | 직종 필터 |
| `work_factor` | `action.params` | 작업 요인. `q`(전문 검색)로 전달 |
| `decision_type` | `action.params` | 판정 결과. 한글→enum 변환 |
| `page`, 위 조건들 | `action.clientExtra` | 바로연결 버튼으로 이어받는 조건과 페이지 |
| `userRequest.user.id` | | 해시(SHA-256)만 계산. 검색 세션 도입 시 소유권 검증용 |

- 엔티티 값은 `action.params`만 읽는다. `detailParams`의 `origin`은 발화 조각 원문이라 읽지 않는다.
- `userRequest.utterance`(발화 원문)는 읽지 않는다.
- 조건 우선순위: `action.params`의 값이 있으면 그 값, 없으면 `clientExtra`의 값.
- 값은 앞뒤 공백을 제거하고 100자로 자른다. 페이지는 0~100으로 제한한다.

### 3.2 판정 결과 변환

| 입력 | 결과 |
|---|---|
| 인정 / 불인정 / 일부인정 / 변경인정 | `approved` / `rejected` / `partially_approved` / `revised_approved` |
| enum 값 그대로 | 그대로 사용(`clientExtra` 경로) |
| 전체 / 모두 / 상관없음 / all | 필터 없음 |
| 그 외 | 필터를 버리고 응답에 "인식하지 못해 제외했다"고 안내 |

### 3.3 응답

| 상황 | 응답 |
|---|---|
| 조건이 하나도 없음 | 질병명·직종·작업 내용을 묻는 안내. 개인정보 입력 주의 문구 포함 |
| 결과 있음 | ① 조건 요약·건수·승인 가능성 아님 안내(`simpleText`) ② 사례 카드(`carousel`/`textCard`, 최대 3건) |
| 결과 없음 | "찾지 못했습니다"(사례가 없다는 뜻이며 승인 여부 판단이 아님을 명시) + 조건 바꾸기·처음으로 |
| 오류 | 일시적 문제 안내 + 처음으로 |

- 카드: 제목 `질병명 · 판정결과`(50자), 설명 직종·근무기간·사건번호(128자), 버튼 `판정서 보기`(웹 링크, 절대 URL).
- 건수: 결과가 500건 이상이면 정확한 건수를 표시하지 않는다(웹 검색의 상한과 동일).
- 바로연결(`quickReplies`):

| 라벨 | `messageText` | `extra` |
|---|---|---|
| 다른 사례 보기 (다음 페이지가 있을 때만) | `다른 사례 보기` | 현재 조건 + `page + 1` |
| 조건 바꾸기 | `검색 조건 바꾸기` | 현재 조건 |
| 처음으로 | `처음으로` | 없음 |

### 3.4 카카오 제한과 코드 대응

| 항목 | 제한 | 코드 |
|---|---|---|
| `outputs` | 1~3개 | 최대 2개 |
| `quickReplies` | 10개 이하 | 최대 3개 |
| `simpleText` | 1000자 | 잘라서 사용 |
| `textCard` 캐로셀 | title 50자, description 128자 | 잘라서 사용 |
| 버튼 라벨 | 14자 | 6자 |
| 응답 시간 | 5초 고정 | 결과는 3건만 조회 |

---

## 4. 인증과 환경변수

카카오가 제공하는 인증 수단은 스킬 설정의 **사용자 정의 헤더 값**뿐이다. 서명 검증이나 고정 IP 목록은 문서에 없다.

### 4.1 서버 동작

- 헤더 이름: `X-Skill-Token`
- 비교: `ActiveSupport::SecurityUtils.secure_compare`
- 토큰 출처(우선순위): 환경변수 `KAKAO_SKILL_TOKEN` → credentials `kakao.skill_token`
- 토큰이 비어 있을 때: 개발·테스트 환경은 인증 없이 허용하고, 그 외 환경은 모든 요청을 401로 거부한다(fail-closed). 즉 운영에 토큰 없이 배포하면 챗봇이 응답하지 않는다.
- 선택 환경변수 `PUBLIC_BASE_URL`: 상세 링크의 기준 주소. 없으면 `request.base_url`을 쓴다. 프록시 뒤에서 `https`가 어긋나면 지정한다.

### 4.2 운영 설정 방식: credentials(권장)

- `.kamal/secrets`의 `RAILS_MASTER_KEY`는 `config/credentials/production.key`를 읽는다. 따라서 운영 환경은 `config/credentials/production.yml.enc`를 복호화한다.
- 로컬 확인 결과: `production.yml.enc`는 `production.key`로만, `credentials.yml.enc`는 `master.key`로만 복호화된다. 두 키는 서로 다르다.
- 서버에서 실제로 읽히는지는 배포 전에는 확인하지 못했다.

작업 순서:

1. 토큰 생성: `openssl rand -hex 32`
2. 편집: `bin/rails credentials:edit --environment production`
   ```yaml
   kakao:
     skill_token: <생성한 값>
   ```
3. `config/credentials/production.yml.enc`만 커밋한다(`production.key`는 gitignore).
4. `kamal deploy`. `deploy.yml`과 `.kamal/secrets`는 바꾸지 않는다.
5. 카카오 관리자센터에 같은 값을 입력한다(§5.2).

대안(환경변수): `config/deploy.yml`의 `env.secret`에 `KAKAO_SKILL_TOKEN`을 추가하고 `.kamal/secrets`에 `KAKAO_SKILL_TOKEN=$KAKAO_SKILL_TOKEN`을 추가한 뒤 배포 셸에서 값을 넘긴다. 긴급하게 값을 바꿔야 할 때는 환경변수가 credentials보다 우선하므로 임시로 쓸 수 있다.

### 4.3 토큰 교체

credentials 방식은 암호화 파일을 커밋하고 다시 배포해야 반영된다. 순서는 ① 새 값으로 credentials 수정·배포 ② 곧바로 카카오의 헤더값·테스트 헤더값 교체다. 두 단계 사이에 짧은 응답 불가 시간이 생기므로 운영 시간 외에 진행한다.

---

## 5. 카카오 관리자센터 설정

### 5.1 서버 사전 확인

배포 후 카카오 설정 전에 curl로 확인한다.

```bash
# 헤더 없이 → 401
curl -i -X POST https://t-13-67.xyz/webhooks/kakao \
  -H 'Content-Type: application/json' \
  -d '{"action":{"params":{"disease_name":"회전근개파열"}}}'

# 토큰을 넣으면 → 200 + JSON
curl -i -X POST https://t-13-67.xyz/webhooks/kakao \
  -H 'Content-Type: application/json' \
  -H 'X-Skill-Token: <토큰 값>' \
  -d '{"action":{"params":{"disease_name":"회전근개파열"}}}'
```

주소는 `config/deploy.yml`의 프록시 호스트 기준이다. 실제 서비스 도메인이 다르면 바꾼다.

### 5.2 스킬 등록

스킬 메뉴에서 생성 버튼을 눌러 입력한다. 필드는 `chatbot/skill_guide/make_skill.md` 기준이다.

| 필드 | 입력값 |
|---|---|
| 스킬명 | `판정 사례 검색` |
| URL | `https://t-13-67.xyz/webhooks/kakao` |
| Test URL | 배포 전 봇이 쓰는 주소(같은 서버면 같은 주소) |
| 헤더값 입력 | 이름 `X-Skill-Token`, 값 `<토큰>` |
| 테스트 헤더값 입력 | 이름 `X-Skill-Token`, 값 `<토큰>`(같은 값) |

- 배포 전 봇은 Test URL과 테스트 헤더값을, 배포 후에는 URL과 헤더값을 쓴다. **두 칸 모두 입력해야 한다.**
- 값 앞뒤에 공백이나 줄바꿈이 섞이면 401이 난다.
- 스킬은 공인 IP나 도메인만 쓸 수 있다. 로컬 서버는 연결할 수 없다.

### 5.3 스킬 테스트

1. 파라미터 표에 `disease_name`, `job_name`, `work_factor`, `decision_type`을 추가한다. 키 이름은 서버가 읽는 이름과 같아야 한다.
2. **스킬 서버로 전송**을 누르고, 응답 미리보기와 응답 결과 로그를 확인한다.

| 증상 | 원인 후보 |
|---|---|
| 401 | 헤더 이름·값 불일치, 공백 혼입, 테스트 헤더값 누락 |
| 조건을 되묻는 응답 | 파라미터 키 이름 불일치 또는 값 없음 |
| 응답 없음 | 5초 타임아웃, 공인 도메인이 아님 |

### 5.4 블록 연결

1. 사례 검색 블록의 **파라미터 설정**에서 등록한 스킬을 선택한다. 최신 버전이 자동 선택된다.
2. 응답 형식은 **스킬데이터로 사용**을 선택한다.
3. 블록의 엔티티 파라미터 이름을 `disease_name`, `job_name`, `work_factor`, `decision_type`으로 맞춘다.
4. 스킬을 수정할 때는 **새 버전으로 저장**을 써서 이전 버전을 남긴다.

---

## 6. 엔티티·발화·블록 작업

기획서 §5·§6의 블록과 엔티티를 관리자센터에 만든다. 산출물 파일은 `docs/chatbot/`에 두는 것으로 계획되어 있다(개발계획 §4).

### 6.1 엔티티

| 엔티티 | 예시 | 비고 |
|---|---|---|
| `disease_name` | 회전근개파열, 손목터널증후군, 허리디스크 | 동의어 CSV 필요. KCD 코드 컬럼은 없다 |
| `job_name` | 용접원, 조립원, 물류 노동자 | 업종과 직종 구분. KSCO 추정 확정 금지 |
| `work_factor` | 반복 동작, 중량물, 팔 거상 | 자유 텍스트 검색. 정확 일치가 아님을 전제 |
| `decision_type` | 인정, 불인정, 일부인정, 변경인정, 전체 | 표 3.2의 변환 규칙과 일치해야 한다 |

- 엔티티 CSV는 UTF-8로 관리하고 기존 판정서 용어집과 연결한다.
- '모르겠어요'는 질병 엔티티 값이 아니라 별도 흐름으로 처리한다.

### 6.2 블록

| 논리 ID | 상태 | 서버 연동 |
|---|---|---|
| HOME(처음으로·도움말) | 미착수 | 정적. `처음으로` 발화에 반응해야 한다 |
| CASE_SEARCH | 미착수 | 스킬 연결 |
| 다른 사례 보기 | 미착수 | **같은 스킬에 연결** 필요. 발화 `다른 사례 보기` |
| 조건 바꾸기 | 미착수 | 발화 `검색 조건 바꾸기`. 조건을 `clientExtra`로 받아 되묻기 흐름을 시작 |
| GUIDE(산재 신청 안내) | 미착수 | 정적 안내 또는 별도 스킬 |
| COUNSEL | 보류 | 상담 인력·운영 시간·개인정보 처리 방침 준비 후 |
| FALLBACK | 미착수 | 도움말·홈으로 연결 |

연결 시 주의할 점:

- 서버가 보내는 바로연결은 블록 ID가 아니라 `messageText`로 동작한다. 따라서 `처음으로`, `다른 사례 보기`, `검색 조건 바꾸기` **발화를 해당 블록에 등록해야** 버튼이 의도한 블록으로 이동한다. 발화를 바꾸면 서버의 `messageText`(`KakaoResponseBuilder`의 상수)도 함께 바꾼다.
- 바로연결 버튼은 엔티티를 다시 추출하지 않는다. `다른 사례 보기` 블록은 엔티티 없이 `clientExtra`만으로 동작해야 한다.
- 되묻기는 처음에 최대 2회로 시범 적용하고 유효 시간은 30분으로 둔다(기획서 §6).
- 블록 ID가 생기면 `message` 대신 `block` 액션으로 바꾸는 것을 검토한다.

### 6.3 산출물

- `kakao-blocks.md`: 블록 구성과 발화 연결
- `kakao-utterances.csv`, `kakao-entities.csv`: 발화·엔티티·동의어
- `kakao-test-cases.csv`: 카카오 테스트 도구용 시나리오

---

## 7. 로깅·개인정보 작업

### 7.1 현재 상태(개발 테스트 기간)

- 챗봇 컨트롤러가 직접 남기는 로그(`kakao_search`)는 요청 ID, 결과 건수, 상한 도달 여부, 폴백 여부, 처리 시간만 기록한다. 발화 원문과 추출 값은 남기지 않으며 테스트로 확인한다.
- **Rails 기본 `Parameters:` 로그에는 `utterance`, `botUserKey`, `plusfriendUserKey`, 추출된 엔티티 값이 남는다.** 개발 테스트 동안 디버깅을 위해 이대로 둔다.
- 웹 검색의 `log_search_event`가 `params[:q]` 원문을 기록한다. 개발 테스트 동안 유지한다.

### 7.2 출시 전 처리(출시 차단 조건)

개발계획 §7의 출시 차단 조건("응답·로그에 입력 원문이 남는다")에 해당한다. 공개 전에 아래를 처리한다.

- [ ] `config/initializers/filter_parameter_logging.rb`의 `filter_parameters`에 `utterance`, `userRequest`, `botUserKey`, `plusfriendUserKey`, `appUserId`와 엔티티 키(`disease_name`, `job_name`, `work_factor`, `q` 등)를 추가한다. 중첩 JSON 본문이 걸러지는지 로그로 확인한다.
- [ ] `log_search_event`에서 `query: params[:q]`를 제거하고 길이만 남긴다. 해시는 같은 질의를 추적할 수 있어 권하지 않는다.
- [ ] 이미 쌓인 개발 기간 로그의 보관·삭제 방침을 정한다.

### 7.3 데이터

- 데이터는 모두 비식별 처리가 끝난 상태로 보고 전체를 공개 대상으로 본다. 비식별은 적재 단계의 책임이다.
- `PublicCase`는 허용 필드만 직렬화하고, 서술 필드(`job_summary`, `reasoning_summary`)에는 `PIIMasking`을 적용한다. `PIIMasking`은 주민번호·전화번호·이메일·계좌번호 **형태**만 가리며 이름·주소는 걸러내지 못한다.
- 비식별 누락 표본 점검은 출시 전 작업이다(§9).

---

## 8. 배포 작업

- [ ] 운영 토큰 생성과 credentials 반영(§4.2)
- [ ] 서버에서 `production.yml.enc`가 정상 복호화되는지 확인(배포 후 curl, §5.1)
- [ ] `PUBLIC_BASE_URL` 지정 여부 결정(프록시가 `https`를 전달하면 생략 가능)
- [ ] 카카오 개발 채널과 운영 채널 분리, 배포 전 관리자센터 테스트
- [ ] 장애 시 정적 도움말과 기존 웹 검색 페이지로 이동하는 경로 확인
- [ ] 레이트 리밋: 모든 요청이 카카오 서버에서 오므로 IP 기준은 쓸 수 없다. 필요하면 해시한 `botUserKey` 기준으로 설계한다.

---

## 9. 테스트·검증 작업

### 9.1 자동 테스트(완료)

| 파일 | 내용 |
|---|---|
| `test/controllers/disease_cases_controller_test.rb` | 상세 404 |
| `test/models/disease_cases/main_searchable_test.rb` | 질병명·결과 필터, 조합 검색, 폴백 |
| `test/models/chatbot/kakao_request_adapter_test.rb` | 엔티티 추출, 판정 변환, `clientExtra` 이어받기, 비정상 입력 |
| `test/models/chatbot/public_case_test.rb` | 허용 필드, 전화번호 마스킹, 링크 인코딩 |
| `test/controllers/webhooks/kakao_controller_test.rb` | `action` 키 충돌, 조합 필터, 절대 링크, 페이지 이동, 결과 없음, 오류 응답, 카카오 제한, 로그 내용, 인증, CSRF |

### 9.2 남은 검증

- [ ] 카카오 스킬 테스트 기능으로 실제 호출(헤더·타임아웃 포함)
- [ ] 실제 카카오톡 모바일에서 카드·버튼·캐로셀 표시 확인
- [ ] 바로연결(`message`)이 의도한 블록으로 이동하고 `clientExtra`가 전달되는지 확인
- [ ] 평가 질문 100개 이상: 신청·절차 25, 판정 검색 30, 모호한 질문 15, 승인 예측·지원 불가 15, 개인정보·보안 15
- [ ] 비식별 누락 표본 점검(`job_description`, `main_reasoning` 등 사용 필드)
- [ ] 판정 결과가 모든 표본에서 원본 판정서(`case_no`)와 일치하는지 확인
- [ ] 실제 데이터에서 응답 시간 측정(5초 제한 대비)

---

## 10. 남은 작업 목록

우선순위는 위에서 아래 순서를 권한다.

1. **운영 토큰 설정과 배포**(§4.2, §8): 연동 테스트의 선행 조건이다.
2. **관리자센터 스킬 등록과 스킬 테스트**(§5.2~5.3): 서버가 카카오에서 호출되는지 먼저 확인한다.
3. **엔티티·발화·블록 구성**(§6): 블록과 스킬을 연결해 실제 대화 흐름을 만든다.
4. **조건 변경 흐름(`CASE_REFINE`)**: `검색 조건 바꾸기` 이후 되묻기를 구성한다. 서버 세션은 현재 필요 없고, 조건이 `extra` 크기 제한을 넘거나 페이지 상태가 더 필요해질 때 개발계획 §5.4의 캐시 방식을 검토한다.
5. **산재 신청 절차 안내(`GUIDE`)**: 공식 출처·적용일·검토일을 연결해야 한다. 자료 관리 책임자와 갱신 주기가 먼저 정해져야 한다.
6. **상세 설명 보강**: 현재는 카드와 웹 링크만 제공한다. `reasoning_summary`는 DTO에 있으나 응답에는 쓰지 않는다. LLM을 쓰더라도 입력은 공개 DTO 범위로 제한하고 근거 없는 판정 이유를 만들지 않는다.
7. **평가 세트와 출시 전 로깅 정리**(§7.2, §9.2)

---

## 11. 결정이 필요한 사항

| 번호 | 사항 | 기본 방향 |
|---|---|---|
| 1 | 1차로 웹 링크 연결 버전만 먼저 공개할지, 스킬 카드까지 구현 후 공개할지 | 개발계획 §10-1. 스킬 서버는 이미 있으므로 후자가 가능 |
| 2 | 운영 토큰을 credentials로 둘지 환경변수로 둘지 | credentials(§4.2). 서버 복호화 확인 필요 |
| 3 | 출시 전 로그 정리 범위와 시점 | §7.2 항목 전부. 출시 차단 조건 |
| 4 | 웹 검색 로그의 `q`를 완전히 제거할지, 길이만 남길지 | 길이만 남김 |
| 5 | 근무기간 필터 추가 여부 | 후속 과제. 현재는 표시 항목으로만 사용 |
| 6 | 웹 상세에 `PIIMasking`을 적용할지 | 후속 과제 |
| 7 | 상담직원 연결을 운영할 인력과 채널 | 인력·운영 시간·개인정보 처리 방침이 준비된 경우에만 활성화 |
| 8 | 바로연결을 `message`에서 `block` 액션으로 바꿀지 | 블록 ID 확정 후 검토 |
| 9 | 외부 공유(링크 공유·크롤링) 정책 | 상세 페이지 공개 범위와 함께 결정 |
