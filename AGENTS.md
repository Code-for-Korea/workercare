# AGENTS.md — 산재상담실 (workercare)

근로복지공단 업무상질병 판정서(61,815건)를 검색하고, 카카오톡 챗봇과 마크다운 응답(`.md`)으로 같은 DB를 제공하는 Rails 앱.
매 세션마다 읽어서 짧게 유지. 상세는 `docs/`, `CONTRIBUTING.md`에 링크하고 여기는 구조, 명령, 관례, 함정만 쓴다.

## 구조

| 경로 | 내용 |
|---|---|
| 루트 | Rails 8.1, Ruby 3.4.9(`.tool-versions`). SQLite(FTS5), propshaft + importmap, pagy, solid_cache/queue, Kamal 2.x |
| `app/controllers/disease_cases_controller.rb` | 웹 검색 `/`(간단), `/search`(상세), `/disease_cases/:case_no`(상세). 한 쪽 12건, 최대 500건 |
| `app/controllers/webhooks/` | 카카오 스킬 `POST /webhooks/kakao`, `/webhooks/kakao/jobs` |
| `app/models/disease_case.rb` + `concerns/disease_cases/` | `searchable`(`/search`, 원문 FTS), `main_searchable`(메인 검색·챗봇 공용, 추출 컬럼 FTS + 구조화 필터) |
| `app/models/disease_cases/normalizer.rb` | 신청서 종류·근무 형태·고용 형태 정규화(순수 Ruby). 규칙은 `config/normalization/rules.yml` |
| `app/models/chatbot/` | 챗봇 전용(요청 어댑터, 응답 빌더, `PublicCase` 허용 필드 DTO, 엔티티 사전) |
| `app/controllers/self_care_form_controller.rb`, `app/models/self_care_form/` | 단계별 사례 찾기. 답은 세션 쿠키에만 두고 DB에 쓰지 않는다. 문서 `docs/self-care-form.md` |
| `app/models/self_care_form/summary_generator.rb`, `app/jobs/self_care_summary_job.rb`, `app/models/self_care_summary.rb` | 결과 화면의 AI 쉬운 요약(EXAONE). 조건별로 한 번 만들어 `self_care_summaries`에 저장하고 turbo-frame으로 교체한다. 문서 `docs/self-care-form.md` 11장 |
| `app/models/apply_guide.rb`, `config/apply_guide/procedure_guides.yml` | 신청 가이드(`/apply-guide`, `.md`). 마크다운→HTML은 `ApplyGuide::HtmlRenderer`(sanitize·https 링크만) |
| `app/models/disease_cases/markdown_renderer.rb` | 검색·상세를 마크다운으로 렌더링. 컨트롤러 `format.md`, 문서 `docs/markdown-responses.md` |
| `lib/tasks/` | `import:*`(KSCO 매핑만은 `import:ksco_mappings`, dry-run 기본), `fts:rebuild`, `normalize:*`, `db:backup`(SQLite 백업), `export:workercare_data`(분석용 CSV), `chatbot:entities:*`, `analysis:report`(통계표를 DB 질의로 재생성), `ksco:prune_codes`(CSV에 없는 KSCO 코드 삭제, dry-run 기본) |
| `DESIGN.md`, `app/assets/stylesheets/` | 디자인 규칙·토큰·컴포넌트와 CSS(`tokens`·`base`·`layout`·`components`·`utilities`). CSS 클래스·대비 검사는 `test/integration/css_classes_test.rb`, `test/design/contrast_test.rb`. 내용은 `DESIGN.md`를 본다 |
| `docs/` | 기획·설계(`workercare*.plan.md`), 정규화(`disease-cases-normalization.md`), 카카오(`kakaotalk/`) |
| `wip/` | 로컬 작업 폴더. **gitignore, 저장소에 없음**(추출·임베딩 스크립트, 대용량 CSV) |
| `docs/ext/` | 외부 서비스 원문 문서의 로컬 사본(카카오 오픈빌더, EXAONE 등). gitignore, .keep만 저장소에 있다 |

데이터: 한 건 = `disease_cases` 한 행. 원문 컬럼 + LLM 추출 컬럼 + KSCO 매핑(`disease_case_ksco_codes`). 스키마 기준은 `db/structure.sql`(`db/schema.rb`는 실제와 다름).

## 개발·테스트 명령

```bash
bin/setup --skip-server        # bundle install + db:prepare (개발 DB는 비어 있다)
bin/dev                        # 웹 3000 (overmind 필요, 없으면 bin/rails server)
bin/rails test                 # Minitest. 단일: bin/rails test test/models/disease_cases/normalizer_test.rb
bin/rubocop app lib test config db bin   # wip/ 제외 (아래 함정 참고)
bin/ci                         # rubocop + audit + brakeman (현재 통과하지 못함)
```

- 테스트는 데이터 없이 돌아간다(레코드를 직접 만든다). 테스트 DB는 `storage/test.sqlite3`.
- 데이터 적재는 **순서 고정**: `import:disease_cases` → `import:ksco_codes` → `import:extracted_disease_cases`. 끝에서 FTS를 rebuild한다. 절차는 `CONTRIBUTING.md` 5.6.
- 마이그레이션 뒤에는 `db/structure.sql`이 갱신됐는지 확인한다.

## 배포

Kamal(`config/deploy.yml`). 서버 SSH 별칭 `web01.workercare`, 이미지 `wagurano/workercare`, 볼륨 `/data/workercare/storage:/rails/storage`(SQLite 파일). `web` 롤 하나다(MCP 롤은 제거). 이전 배포에서 `mcp` 컨테이너가 남았으면 `bin/kamal app stop --roles=mcp`로 정리한다. 비밀값은 `.kamal/secrets`, `RAILS_MASTER_KEY`. 절차는 `docs/server-setup-ubuntu.md`.

EXAONE 쉬운 요약은 기본 꺼짐이고 `config/deploy.yml`에는 키가 없다(`env.secret`에 넣으면 비밀값이 없을 때 모든 배포가 멈추기 때문). 켜려면 **사용자가 직접** 세 가지를 한다: ① `.kamal/secrets`에 `EXAONE_API_KEY=$EXAONE_API_KEY` 줄 추가(값이 아니라 환경 변수 참조, 이 파일은 커밋하지 않고 셸에 키를 둔다) ② `config/deploy.yml`의 `env.secret`에 `EXAONE_API_KEY` 추가 ③ `env.clear`에 `EXAONE_SUMMARY_ENABLED: 1` 추가. 그다음 배포한다. 큐는 `exaone`(스레드 1개, `config/queue.yml`)이라 초당 1회 한도를 지킨다.

운영 DB에 rake를 돌릴 때: `bin/kamal app exec --roles=web --reuse "bin/rails ..."`. `--roles=web`을 유지한다. 옛 `mcp` 컨테이너가 남아 있으면 `--roles`를 빼면 둘에서 동시에 실행돼 `SQLite3::BusyException: database is locked`가 난다.

## 알려진 함정

1. **정규화 컬럼은 원본을 덮어썼다** — `application_type`(`|` 결합 토큰: 요양급여·휴업급여·유족급여·장의비·추가상병·장해급여·미지급보험급여·재신청·기타), `work_type`, `employment_type`은 범주만 남고 부가 표기는 `*_detail`에 있다. 필터는 `application_type`을 파이프 경계 매칭, 나머지를 exact match로 쓴다. 옛 표기 입력(MCP)은 `Normalizer`로 변환해 매칭한다. 재임포트도 Normalizer를 거치므로 원본 표기로 돌아가지 않는다. 규칙을 바꾸면 `docs/disease-cases-normalization.md`도 고친다.
2. **정규화 백필은 되돌릴 수 없다** — `normalize:disease_cases`는 dry-run이 기본이고 `[apply]`가 덮어쓴다. 먼저 `bin/rails db:backup`으로 DB 파일(`VACUUM INTO`)을 백업한다. 복구는 이 파일로 바꿔 끼운다(`CONTRIBUTING.md` 5.6.1). `export:workercare_data` CSV는 분석·공유용 스냅숏이지 복구 수단이 아니다. 운영 반영은 사용자가 직접 한다.
3. **`death_status`·`heavy_lifting`·`work_relevance_eval`의 빈값은 NULL** — `''`와 NULL의 구분은 없다.
4. **application_type 다중 선택은 OR** — "둘 다 있는 건(AND)"은 보류 상태다. `burden_body_part`·`job_name` 정규화(태그/연결 테이블 검토 포함)도 후속이고 챗봇에 영향을 준다.
5. **FTS 인덱스 두 개** — `disease_cases_fts`(원문, `/search`), `disease_cases_extracted_fts`(추출, 메인·챗봇). 트리거로 갱신되지만 대량 적재·`update_all`은 트리거를 거치므로 필요하면 rebuild한다.
6. **필터 옵션은 캐시** — 하루 캐시(`Rails.cache`). 적재 뒤 바로 반영하려면 키를 지운다(예: `disease_cases/burden_body_part_token_counts`, `disease_cases/application_type_options`).
7. **카카오 스킬은 항상 200 + 5초** — 오류·결과 없음도 안내 문구 응답이다. 챗봇은 `main_search(fts_as_filter: true)`로 최신순이고 웹은 bm25 순이다. 헤더 `X-Skill-Token` 검증. 같은 발화를 두 블록에 넣으면 중복 오류가 난다.
8. **챗봇 응답은 `Chatbot::PublicCase` 허용 필드만** — 새 필드는 비식별 확인 후 추가한다. 엔티티 CSV(`docs/kakaotalk/entities/*.csv`)는 생성물이므로 `config/chatbot/entities/*.yml`을 고치고 `chatbot:entities:build`.
9. **`업묵부담_가중요인_노출`(업묵) 철자** — 추출 CSV 헤더와 import 태스크가 같은 오타를 읽는다. 한쪽만 고치면 컬럼이 비어 들어간다.
10. **CI가 꺼져 있다** — `.github/workflows/ci.yml_`(끝에 `_`)는 비활성. rubocop은 `wip/`까지 검사해 실패하고 brakeman·bundler-audit도 실패 중이다. 새 변경이 상태를 더 나쁘게 만들지 않는지 로컬에서 확인한다.
11. **마크다운 응답은 `.md` 확장자와 `Accept`로만 결정** — User-Agent로 봇에게만 다르게 주지 않는다(cloaking). 모든 표현에 `Vary: Accept`와 서로를 가리키는 `Link` 헤더가 붙는다. 본문은 `PIIMasking`을 거치지만 웹 HTML 상세는 아직 아니다. 새 컬럼을 노출하면 `MarkdownRenderer`의 이스케이프(`cell`)와 비식별을 같이 본다. MCP는 제거됐다(`action_mcp_*` 테이블은 `DropMcpTables` 마이그레이션으로 삭제).
12. **단계별 사례 찾기는 저장하지 않는다** — 답은 암호화 세션 쿠키(`session[:self_care_form]`, 직접 입력 30자 상한)에만 두고 URL·DB·로그에 남기지 않는다(`filter_parameters`에 `free_text`·통계 답 키). 결과 목록에는 질병명·직업명·신체부위·판정 결과·연도·원문 링크만 쓰고 판정서의 서술형 요약은 목록에 노출하지 않는다. **예외는 "판정서 쉬운 요약(AI 작성, 참고용)" 하나다**: `EXAONE_SUMMARY_ENABLED`와 `EXAONE_API_KEY`가 모두 있을 때만 켜지고(기본 꺼짐), 조건(사전 개념 이름·판정 결과)별로 한 번 만들어 저장한 글을 보여 준다. "AI 작성, 참고용" 표시·"원문을 꼭 확인하세요" 고지·근거 사례 링크가 있어야 하고, 승인 여부 예측·가능성·유리/불리·신청 권유 표현은 프롬프트와 저장 전 검사(`SummaryGenerator::FORBIDDEN_PHRASES`)로 막는다. 방문자가 직접 입력한 글은 요약 조건에도 EXAONE 요청에도 넣지 않는다. 단계·허용값은 `SelfCareForm::Flow` 한 곳이다. 신체부위 직접 입력은 `BodyPartMatcher`가 사전 개념을 찾고(한 글자 표기는 엄격 규칙), 못 찾으면 조건 없이 찾고 알린다. `job_name_any`는 `main_search_params` 허용 목록에 있는 공용 필터다(`/search`가 폼의 직종 조건을 이어 받는다). 신청 가이드 문구는 출시 전 공식 출처로 재확인한다. **구글 폼으로 통계를 보내는 기능은 켜져 있다**(`config/self_care_form.yml`의 `enabled: true`, 샘플 폼 entry id 8개. 사용자 결정 2026-11-11). 선택 동의한 사람만 보내고, 보관은 최대 3년·해마다 점검·삭제 담당은 산업재해 프로젝트 팀이다. **법률·개인정보 검토는 하지 않았다**(권장). 테스트는 `test_helper.rb`가 기본으로 꺼진 설정을 끼워 실제 요청을 막는다. 전송은 [결과 보기] POST에서 마지막 전송값(SHA-256 해시를 세션에 보관)과 다를 때만 하고 GET은 보내지 않으며, `entries`에 id가 있는 키만 전송한다. **원문 전송은 직종 직접 입력만 예외다(신체부위 직접 입력·검색어·챗봇 발화는 보내지 않는다).** 직업을 직접 입력했으면 사전(`JobMatcher`)에서 찾은 직종 이름을, 못 찾으면 입력한 말을 번호 형태를 가리고(`PIIMasking`) 30자로 잘라 보낸다(사용자 결정 2026-11-11; 이름 입력 위험은 `docs/self-care-form.md` 10.1). 신체부위 신체부위 직접 입력 원문·IP·세션 ID는 폼 필드로 보내지 않으며, 콜백은 `rack.response_finished`(Rack 3 표준)에 단다. 시험은 `CONFIRM=1 bin/rails self_care_form:send_test`(시트에 `[테스트]` 행이 남으니 시험한 사람이 지운다). 자세한 절차는 `docs/self-care-form.md` 10장.
13. **CSS는 렌더된 HTML 기준으로 검사한다** — 새 클래스는 화면(뷰·헬퍼·JS)에서 실제로 쓰여야 하고, 아니면 `css_classes_test`가 실패한다. 예외는 `test/support/css_class_allowlist.yml`이고 이유를 적는다. 중첩, 선택자 이스케이프(`md\:`), `@import`는 쓰지 않는다(같은 테스트가 막는다). 색 토큰을 바꾸면 `contrast_test`가 대비를 확인한다. 글꼴 Pretendard는 jsdelivr CDN이라 CSP를 켜면 `style_src`와 `font_src` 둘 다에 `https://cdn.jsdelivr.net`이 필요하다. 규칙은 `DESIGN.md`.

## 개인정보·보안

- 판정서는 비식별 처리본이지만 완전하다고 믿지 않는다. `PIIMasking`은 번호 형태만 가린다. 이름·주소는 못 거른다.
- 사용자 발화 원문을 저장·로그하지 않는다. **예외는 단계별 사례 찾기의 직종 직접 입력 한 칸뿐이다**: 선택 동의한 경우에만 가려서(번호 형태, 30자 이내) 구글 폼으로 보낸다(함정 12, 사용자 결정 2026-11-11). 신체부위 직접 입력, 검색어(`q` 등), 챗봇 발화, 로그에는 이 예외를 적용하지 않는다. 테스트에 실제 개인정보를 넣지 않는다.
- 비밀값(`config/master.key`, `config/credentials/*.key`, `.env*`, `.kamal/secrets`)과 `wip/`, 원본 데이터, `storage/backups`·`storage/exports`의 백업·CSV는 커밋하지 않는다(`/storage/*`가 gitignore). 내보내기 기본은 판정서 본문 제외이고 `FULL_TEXT=1` 결과는 외부에 공유하지 않는다.
- **외부 LLM·임베딩 서비스로 보낼 수 있는 것은 공개·비식별 판정서(요인 컬럼, 필요할 때 짧은 발췌)뿐이다**(2026-11-14 결정. 현재 쓰는 곳은 LG EXAONE 쉬운 요약). **방문자가 입력한 정보(단계별 사례 찾기의 직접 입력과 답, 검색어, 챗봇 발화)는 외부 LLM으로 보내지 않는다.** 요약은 운영자가 미리 만들어 저장한 글이다(방문자 요청이 처음 만들 때 호출을 일으킬 수는 있으나 보내는 것은 판정서뿐). 새 서비스나 새 용도는 팀 합의가 먼저다. EXAONE 약관 제3자 호출 조항 위험과 학습 이용 동의(2026-11-14)는 `docs/self-care-form.md` 11장.
- **승인 가능성을 예측하지 않는다.** "당신의 사건은 인정됩니다" 류의 응답을 만들지 않는다. 제도 안내는 출처와 확인일을 함께 적는다(`config/locales/procedure_guides.yml`).

## 코딩·커밋 관례

- 스타일은 `rubocop-rails-omakase`. UI 문구·주석은 한국어 기본, 화면 문구는 `config/locales/ko.yml`.
- 브랜치: `feat/…`, `chore/…`, `fix/…`. 기본 브랜치는 `main`.
- 커밋 제목은 한국어 `~합니다` 한 줄(`feat:`, `fix:`, `chore:`, `docs:` 접두어 허용). 한 커밋은 한 가지 일만(코드·문서·데이터 도구 분리).
- **커밋은 경로를 지정한다.** 이 저장소는 파일이 미리 스테이지되는 일이 있다: `git commit -m "제목합니다" -- path/a.rb path/b.rb`. zsh는 변수를 단어 분리하지 않으므로 경로 목록은 배열로 넘긴다.
- **커밋 메시지와 PR 본문에 `Co-Authored-By: ...`, `Generated with ...` 문구를 넣지 않는다.**
- 구조·검색·스키마·정규화가 바뀌면 `README.md`, `USERGUIDE.md`, `CONTRIBUTING.md`, `docs/`와 이 파일의 함정 목록을 같이 고친다. 상세 내용은 이 파일에 복사하지 말고 링크한다.
