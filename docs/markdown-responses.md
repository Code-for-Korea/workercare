# 마크다운 응답 (검색·검색결과·상세)

상태: 구현됨. MCP 서버를 제거하면서 그 기능 중 검색·검색결과·상세만 웹 앱이 직접 마크다운으로 제공한다. 인정·불인정 요인 비교, 증거 제안, 절차 안내, 프롬프트는 이전하지 않고 삭제했다(git 이력에 있다).

## 주소

| 용도 | HTML | 마크다운 |
|---|---|---|
| 간단한 검색 | `/` | `/index.md` (또는 `/`에 `Accept: text/markdown`) |
| 상세 검색 | `/search` | `/search.md` |
| 판정서 상세 | `/disease_cases/:case_no` | `/disease_cases/:case_no.md` |

- 같은 주소에 `Accept: text/markdown, text/html;q=0.9`를 보내도 마크다운을 받는다. q값을 비교해 정하므로 `text/html, text/markdown;q=0.5`는 HTML이다.
- 둘 다 원하지 않는 Accept(예: `application/pdf`)는 `406 Not Acceptable`이다. 조용히 HTML을 주지 않는다.
- 브라우저는 `Accept: text/html,…,*/*`를 보내므로 지금처럼 HTML을 받는다.
- 봇의 User-Agent로 응답을 바꾸지 않는다(cloaking 방지). `Accept`와 확장자로만 결정한다.

## 헤더

| 헤더 | 값 |
|---|---|
| `Content-Type` | `text/markdown; charset=utf-8` |
| `Vary` | `Accept` (HTML·마크다운 모두. CDN이 표현별로 캐시하게 한다) |
| `Link` | 마크다운 응답: `<HTML 주소>; rel="alternate"; type="text/html"` / HTML 응답: `<마크다운 주소>; rel="alternate"; type="text/markdown"` |

HTML 응답의 `<head>`에도 `<link rel="alternate" type="text/markdown" href="…">`가 있다.

## 검색 파라미터

HTML 화면과 같은 파라미터를 같은 코드로 처리한다(`DiseaseCasesController#perform_search`). 응답 맨 아래 "검색 방법" 표에 허용값이 코드에서 만들어져 들어간다.

| 파라미터 | 설명 |
|---|---|
| `q` | 검색어(전문 검색) |
| `job_name`, `job_description`, `disease_name` | 부분 일치 |
| `job_name_any[]` | 핵심어 중 하나라도 직업명에 포함(띄어쓰기 무시). 예: `job_name_any[]=택배&job_name_any[]=배송` |
| `application_type[]` | 신청서 종류. 여러 개를 주면 하나라도 포함(OR) |
| `employment_type`, `work_type`, `work_relevance_eval` | 정규화된 범주값 |
| `death_status` | `Y`이면 사망 사례만 |
| `burden_body_part[]` | 부담 신체 부위 |
| `sort` | 생략하면 관련도순, `recent`는 최신순 |
| `page` | 쪽 번호. 한 쪽 12건, 최대 500건 |

`/search.md`는 위에 더해 `result`, `year`, `decided_on_from`, `decided_on_to`, `disease_category[]`, `body_part[]`, `search_in[]`를 받는다.

## 응답 구성

- 검색: 제목, 검색어·건수·쪽, 결과 표(연번이 `.md` 상세 링크), 이전·다음 쪽 링크(쿼리 유지), 검색 방법 표, 고지문.
- 상세: 제목, 메타 목록(연번·심의결과·질병분류·신체부위·판정일·원문 링크), 추출 정보 표, 판정서 각 절(`## 라벨`), 판단 주요 근거, 고지문.
- 정확한 결과가 없어 유사 결과를 보여 줄 때는 안내 한 줄이 붙는다.
- MCP의 `confidence_score`, 승인율 통계는 옮기지 않았다. 개인의 승인 가능성을 예측하지 않는다는 원칙이다.

## 이스케이프와 비식별

- 표 셀은 개행을 공백으로, `|`를 `\|`로, `<`·`>`를 `&lt;`·`&gt;`로 바꾼다(`MarkdownRenderer#cell`).
- 판정서 본문은 인용 블록(`> `)으로 넣는다. 본문 속 `#`, `-`가 문서 구조를 만들지 못한다.
- 본문·추출 정보는 `PIIMasking.mask`를 거친다(주민번호·전화번호·이메일·계좌번호 **형태**만 `***`). 이름·주소 같은 서술형 개인정보는 걸러내지 못한다. 웹 HTML 상세는 아직 마스킹하지 않는다.

## MCP 도구와의 대응

| 제거한 MCP 기능 | 지금 |
|---|---|
| `search_disease_cases` | `/search.md`, `/index.md` |
| `disease-case://{case_no}` 리소스 | `/disease_cases/:case_no.md` |
| `compare_approval_factors`, `suggest_evidence`, `get_procedure_guide`, 프롬프트 3종 | 제공하지 않음 |

## llms.txt

`public/llms.txt`에 사이트 요약과 `.md` 링크 목록을 두었다(정적 파일, 링크는 상대 경로). 대부분의 AI 도구가 읽지 않으므로 보조 수단이다. 도메인이 정해지면 절대 URL로 바꾸는 것을 검토한다.

## 구현

- `config/initializers/mime_types.rb`: `text/markdown`을 `:md`로 등록.
- `DiseaseCasesController`: `respond_to`의 `format.md`, `set_representation_headers`(after_action).
- `DiseaseCases::MarkdownRenderer`: 렌더링(ERB는 HTML 이스케이프가 걸려 쓰지 않았다).
- `config/routes.rb`: root는 확장자를 받지 못해 `/index`를 따로 뒀다.
- 테스트: `test/models/disease_cases/markdown_renderer_test.rb`, `test/controllers/disease_cases_controller_test.rb`.

## 후속 검토

- `public/robots.txt`는 현재 모든 봇을 허용하는 기본 파일이다. 판정서의 학습 이용 허용 여부와 `GPTBot`·`OAI-SearchBot`·`ChatGPT-User`·`Claude-User` 정책은 팀이 정한다.
- 웹 HTML 상세에도 `PIIMasking`을 적용할지.
- 마크다운 요청 로그에 `format`과 User-Agent 앞 60자를 남긴다(`log_search_event`). LLM fetcher 사용량을 본다.
