# Solar LLM 추가 추출 계획

상태: **계획**. 3단계(rake 태스크)는 **구현됨(이 PR)**이고 실행·적재는 아직입니다. 확인일 2026-11-18. 컬럼 이름·기준값은 모두 제안이며 팀이 확정하기 전까지 바뀔 수 있습니다.

## 1. 배경과 현재 상태

판정서 61,815건에서 LLM으로 추출한 컬럼은 21개입니다. 기존 추출 스키마와 프롬프트는 `wip/cerebras_prompts.rb`에 있습니다(로컬, 저장소에 없음). 개발 DB(`storage/development.sqlite3`)에서 채움률(NULL도 빈 문자열(공백만 있는 값 포함)도 아닌 행 비율)을 직접 확인했고 제시된 수치와 같았습니다. 숫자 컬럼(`weekly_work_hours`·`max_item_weight`·`daily_total_weight`)에는 빈 문자열이 없어 NULL만 셉니다.

| 컬럼 | 채움률 | 비고 |
|---|---|---|
| `job_name`, `main_reasoning`, `work_relevance_eval` | 88.8~89.0% | 추출된 행의 기준선 |
| `weekly_work_hours` | 60.3% | 12주/4주 평균 구분 없음 |
| `employment_type` | 43.0% | |
| `max_item_weight` | 51.4% | |
| `daily_total_weight` | 19.5% | |

- 추출이 전혀 없는 행은 6,829건(약 11%)입니다. `job_name`·`main_reasoning`·`work_relevance_eval`이 모두 NULL 또는 빈 문자열인 행이며, 이 행들은 `weekly_work_hours`·`burden_body_part`도 모두 비어 있습니다.
- 노출 여부 Y/N 플래그는 이전 시험에서 거의 채워지지 않았습니다.
- 없는 것: 불인정 사유(닫힌 코드북), 질환군별 변수, 기저질환·기왕증, 과거 근무경력, 건강검진, 화학물질, 작업환경, 특별진찰·역학조사.
- 인정 결과 분포(`result`): approved 30,357 / rejected 23,602 / partially_approved 6,826 / revised_approved 1,030.

## 2. 추가 추출 컬럼 후보 (우선순위)

| 순위 | 컬럼(제안) | 형태 | 대상 |
|---|---|---|---|
| 1 | `denial_reason_codes` + 근거 문장 | 닫힌 다중 enum: 업무량 미달 / 기왕증·자연경과 / 노출 불충분 / 상병 불일치 / 시간·인과 불명확 / 기타 | 불인정 건 |
| 2 | 기저질환(`comorbidities`, `smoking`, `alcohol`, 기왕증 `source`). 기존 후보 `preexisting_conditions`를 이 항목으로 합칩니다 | 다중 enum + 흡연·음주 enum | 뇌심혈관·근골격계 |
| 3 | 과거 근무경력(`prior_careers[]`, `prior_career_months`) | 배열(기간·직종·작업) + 숫자 | 전체 |
| 4 | `overwork_type`(만성/단기/급성/해당없음), `hours_12w`, `hours_4w` | enum + 숫자 | 뇌심혈관(고용노동부 고시 인정기준) |
| 5 | 건강검진(`checkup_exists`, `special_exam_done`, 이상 소견 플래그) | 여부 + 범주 플래그(원 수치는 저장하지 않음) | 뇌심혈관 중심 |
| 6 | 화학물질(`chemical_exposure`, 물질 분류, 물질명, `workplace_measurement`) | enum + 목록 | 해당 사건(질환군 NULL·암·호흡기 등) |
| 7 | 작업환경(`noise`·`dust`·`vibration`·`heat`·`cold`·`confined`, `indoor_outdoor`) | enum | 근골격계·기타 |
| 8 | `special_exam`, `epi_survey`, `epi_result` | 여부 + 결과 | 근골격계·암·호흡기 |
| 9 | 질환군별 노출: 암(물질, 노출 연수), 소음성 난청(dB, 연수), 정신(사건 유형 enum) | 6·7과 겹치는 부분(물질·소음)은 같은 스키마를 씁니다 | 해당 질환군 |

우선순위는 불인정 사유(1)를 먼저 두고, 신규 검토 항목은 실현 가능성이 높은 순(기저질환·과거 근무경력 → 건강검진 → 화학물질 → 작업환경)으로 놓았습니다. 4·8·9는 아직 같은 방식의 실현 가능성 검토를 하지 않았습니다. 8의 `special_exam`(특별진찰)은 5의 `special_exam_done`(특수건강진단)과 다른 것입니다.

### 2.1 기저질환·과거 근무경력·건강검진·화학물질·작업환경 검토

아래 비율은 원문 7개 컬럼(`statement`, `claim_purpose`, `application_content`, `applicant_claim`, `medical_records`, `recognized_facts`, `committee_decision`)에서 키워드(`instr()`) 하나라도 있는 건의 **언급률**이며 확인된 사실이 아닙니다. `related_laws`는 법조문 상용구가 99% 이상이라 뺐습니다. N=61,815(질환군: 근골격계 42,596 / 뇌심혈관 12,547 / NULL 6,290 / 기타 381). 예상 채움률은 추정이고 정답 200건(6.1)으로 검증합니다.

| 항목 | 주 컬럼 | 언급률 | 추출 가능성 | 예상 채움률 |
|---|---|---|---|---|
| 기저질환 | `medical_records`, `recognized_facts` | 67.0%(고혈압 15.8, 당뇨 11.2, 흡연 27.5, 음주 23.6, 퇴행성 29.4, 기왕증 1.6) | 높음 | 뇌심혈관 90%+, 근골격계 55~60% |
| 과거 근무경력 | `recognized_facts`의 "입사 전 근무이력"·"직업력" 절 | 직업력 절 26.0%(16,073건), 근무이력 28.7% | 높음 | 70~80%, 기간은 약 60% |
| 건강검진 | `medical_records` | 29.1%(뇌심혈관 92.9%, 근골격계 7.4%). 단위 수치(mmHg·mg/dL) 4,196건 6.8%, 특수건강진단 479건 0.8% | 중간~높음 | 전체 25~30%, 뇌심혈관 90%+ |
| 화학물질 | `recognized_facts` | 9.7%(질환군 NULL에서 48.5%). 작업환경측정 1,735~1,885건 | 중간 | 전체 5~10%, 해당 사건 80%+ |
| 작업환경 | `committee_decision`, `recognized_facts` | 겉보기 82.3%지만 "작업환경"은 의결문 상용구. 구체 단서는 소음 5.4, 분진 7.3, 진동 12.1, 밀폐 3.8, 고온 1.8, 한랭 1.4%. 정형 양식("실내 또는 실외…") 181건 | 중간 | 정성 30~40%, 수치 1~2% |

**기존 컬럼과의 겹침**
- `aggravating_factors`(41,851건 채움)에 기저질환 언급은 2,065건뿐이라 새 컬럼이 필요합니다.
- `job_tenure_months`(85%)는 현 직장 근속뿐이고 이전 직장 목록은 없습니다.
- `other_harmful_factors`(65.7%)에 소음·진동·분진 언급이 10,404건, 화학·용제가 399건 있습니다. 작업환경·화학물질은 이 컬럼과 대조해 중복·불일치를 확인합니다.

**이전 로컬 시험**(`wip/`, 저장소에 없음)
- `wip/extract_solar_work.rb` 스키마의 화학물질 배열은 5~25건 시험에서 모두 채움 0%였습니다. 스키마를 다시 설계해야 합니다.
- `wip/extracted_medical_info.csv`(3,233행)와 `wip/extracted_medical_solar_test.csv`(2,000행)의 건강검진이력 채움 67~85%는 원문 언급률 29%보다 높습니다. 표본 치우침이나 환각이 의심되므로 원문과 대조합니다.

**권장 스키마**: 각 필드는 `{value, evidence_quote(80자 이하, 번호 마스킹), mention: 있음|없음|언급없음}` 형태입니다.
- 기저질환: `comorbidities` 다중 enum(고혈압, 당뇨, 이상지질, 비만, 퇴행성, 심장질환, 뇌혈관, 기타), `smoking`(현재/과거/비흡연/미확인), `alcohol`(음주/비음주/미확인), 기왕증 `source`(사실 기록/위원회 판단).
- 과거 근무경력: 배열 `{start_ym, end_ym, occupation(KSCO 대분류), task(40자 이하)}`와 `prior_career_months`. 사업장명은 마스킹돼 있어 쓰지 않습니다.
- 작업환경: `noise`·`dust`·`vibration`·`heat`·`cold`·`confined`(노출/비노출/불명), `indoor_outdoor`, 선택 `noise_dba`.
- 화학물질: `chemical_exposure`(있음/없음/불명), 물질 분류 enum(유기용제, 석면, 중금속, 분진, 금속가공유, 기타), 물질명 목록, `workplace_measurement`(초과/미만/불검출/미확인). CAS 번호·별칭(크실렌/자일렌) 매핑은 사후 처리합니다.
- 건강검진: `checkup_exists`, `special_exam_done`, 이상 소견 플래그(고혈압 범위, 공복혈당 이상, 고콜레스테롤).

**추출 시 주의**
- '없음'과 '언급 없음'을 구분합니다(흡연, 화학물질 부정문 "화학물질이 없으며").
- 단위를 분리해 정규화합니다(mmHg, mg/dL, mg/m³·mg/㎥, ppm, dB(A)). 여러 해 검진은 배열로 받고 "가장 최근" 규칙을 둡니다.
- 키워드 오탐이 있습니다("작업환경"·"경력" 상용구, "흡연시간 등 휴식시간", "소음을 검사하는 공정"). 키워드는 대상 선별용이고 판독은 LLM이 합니다.
- 양식이 있는 건과 서술형 건의 채움률을 따로 측정합니다.
- 프롬프트에는 필요한 컬럼(`medical_records`, `recognized_facts`, `committee_decision`)만 보내 토큰을 줄입니다(`recognized_facts` 평균 2,137자).

**민감정보**: 건강검진 수치는 비식별이어도 민감합니다. DB에는 범주 플래그만 저장하고 원 수치는 로컬 분석용에 한정하며 웹·챗봇에는 노출하지 않습니다(AGENTS.md 함정 8의 허용 필드 원칙).

**분석 가치**(연관성 서술만, 승인 가능성 예측 금지)
- `committee_decision`의 기왕증·퇴행성·기존질환 언급은 불인정 16.6%(3,924/23,602), 인정 9.8%(2,960/30,357)입니다. 의결문이 불인정 이유를 서술하므로 인과가 아닙니다.
- 뇌심혈관계의 고혈압·당뇨 언급은 불인정 69.9%, 인정 69.3%로 거의 같습니다.
- 화면에 표기할 때는 "언급 빈도이며 개인 사건 결과를 예측하지 않습니다"와 출처·확인일을 함께 적습니다.

**한계**: 키워드 기준이라 정답 200건 라벨(6.1)로 검증해야 합니다. 질환군 NULL 6,290건의 성격과 연도별 양식 차이는 확인하지 못했습니다.

판정위원회 지역과 인용 판례 번호는 정규식으로 뽑고 LLM을 쓰지 않습니다.

## 3. 과제

| | 내용 |
|---|---|
| A | 불인정 사유 분류. 미리 계산한 통계를 화면·`/about`에 보여 줍니다. 방문자 요청마다 LLM을 호출하지 않습니다. |
| B | 질환군별 보충 추출. `disease_category`별 작은 JSON 스키마를 두고 structured outputs로 enum을 고정합니다(자유 문자열은 범주가 폭증합니다). 2.1의 기저질환·과거 근무경력·건강검진·화학물질·작업환경 후보를 이 과제에 묶고, 우선순위는 2장을 따릅니다. |
| C | 빈 행 6,829건 재추출. 기존 스키마를 쓰고 모델만 바꿉니다. |
| D | 기존 추출 품질 점검. 정답 200건과 비교하고, 결과가 뒤집힌 건과 `work_relevance_eval`↔`result` 모순을 표시합니다. |
| E | `burden_body_part`·`job_name` 정규화 후보 제안. 사람이 승인합니다(AGENTS.md 함정 4의 후속). |

## 4. 모델·API

근거는 `docs/ext/solar/`의 로컬 사본입니다(gitignore, 저장소에 없음. 저장일 2026-11-18).

| 항목 | 값 | 출처 |
|---|---|---|
| 엔드포인트 | `https://api.upstage.ai/v1/chat/completions` | `chat-completions-api.md` |
| `solar-mini4` | 입력 $0.10 / 출력 $0.40 / 캐시 $0.01 (100만 토큰당), 컨텍스트 512K, structured outputs 지원 | `solar-mini-4.md` |
| `solar-pro4` | 입력 $0.30 / 출력 $1.20 / 캐시 $0.06 | `solar-pro-4.md` |
| 한도(Solar Mini 4) | Tier 0 100 RPM·250K TPM, Tier 1 400·500K, Tier 2 2,000·750K. Legacy Tier는 100 RPM·50K TPM | `rate-limits.md` |
| 한국 리전 | `https://kr.api.upstage.ai`. **Closed Beta**, 별도 권한 필요 | `region-usage.md` |
| Solar Mini 4.5 Preview | `solar-mini-4-5-preview`, Private Beta 11/14~11/30 무료, 예고 없이 중단 가능 | `soloar-mini-4-5-preview.txt` |

### 데이터 이용 조건

- 유료 Solar Mini 4: 입력은 학습에 쓰이지 않고 저장되지 않습니다(`solar-mini-4.md`, "API privacy").
- 약관 제22조(회원 입출력 데이터): 무료로 제공되는 서비스의 입출력은 학습에 쓰일 수 있습니다(유상 판매 전제의 일시 무료는 제외라고 적혀 있으나 해석은 사람이 확인).
- Solar Mini 4.5 Preview: 베타 기간 입출력이 저장되고 학습·평가에 쓰일 수 있습니다. 운영 실행에도 씁니다(6.4 사용자 결정 2026-11-20). 보내는 것은 공개·비식별 판정서로 한정하고, 기간(11/30) 종료 뒤에는 쓸 수 없습니다.
- 약관 제7조(회원의 일반적 의무), 제9조(서비스의 이용), 제22조(입출력 데이터), 제26조(제재 조치)는 출시 전 사람이 직접 읽습니다. 제7조에는 서비스 결과물로 경쟁 모델을 학습하지 못한다는 조항도 있습니다.
- 한국 리전과 레이트 한도 등급은 계정별로 달라질 수 있으니 실행 전 콘솔에서 확인합니다.

## 5. 데이터 원칙

- 보내는 것은 공개·비식별 판정서뿐입니다. `PIIMasking`은 번호 형태만 가리고 이름·주소는 걸러내지 못하므로 비식별을 완전하다고 믿지 않습니다.
- 사용자 입력(단계별 사례 찾기 답, 검색어, 챗봇 발화)은 외부 LLM으로 절대 보내지 않습니다.
- 승인 가능성을 예측하는 출력을 만들지 않습니다.
- 추출 결과는 판정서에 근거한 사실만 담습니다(근거 문장을 함께 받아 검증).

## 6. 실행 방식

**로컬 PC에서 시험하고, 서버에서 스크립트로 전체 추출을 긴 시간 실행합니다.**

### 6.1 로컬 시험

1. 정답 200건을 만듭니다. `bin/rails "solar:gold_sample[200]"`은 `disease_category`(NULL은 `(NULL)`) × `result`(승인·불승인 등 4종) 층으로 비례 배분하고, 층마다 최소 3건을 둡니다. 결과는 `storage/exports/solar/gold/gold_sample_200_20261118.csv`입니다. 시드는 기본 `20261118`이고 `SEED`로 바꿉니다. 경로는 `OUT_FILE`로 바꿉니다. 본문은 읽지 않고 LLM도 쓰지 않습니다. 라벨 칸(`comorbidity_*`, `prior_career_*`, `labeler`, `notes`)은 사람이 채웁니다.
2. 모델(`solar-mini4`, `solar-pro4`, 필요 시 4.5 Preview)·프롬프트·스키마를 비교합니다.
3. 정확도 기준(제안값, 팀이 확정)을 넘으면 전체 실행으로 갑니다.
4. 파일럿에서 판정서 평균 토큰을 재고 전체 비용과 소요 시간을 추정합니다.

가정 예시(아래 6.4의 200건 실측으로 교체됨): 입력 4,000토큰·출력 500토큰이면 61,815건은 입력 약 2.5억·출력 약 0.3억 토큰이고 `solar-mini4` 기준 약 $37입니다. 한도가 250K TPM이면 분당 약 55건이라 약 19시간이 걸립니다.

### 6.2 서버 전체 실행

- **태스크**: `lib/tasks/solar_extract.rake`의 `solar:extract[과제]`. 과제는 `comorbidity`(기저질환, `comorbidity-p4`·`comorbidity-s3`·검증기 `comorbidity-v4`)와 `prior_career`(과거 근무경력, `prior_career-p4`·`prior_career-s3`·검증기 `prior_career-v4`)입니다. 기본은 dry-run입니다.

```bash
# dry-run(기본): 호출 없이 건수·토큰·비용·소요 시간만 추정합니다
LIMIT=20 bin/rails "solar:extract[comorbidity]"

# 실제 호출(UPSTAGE_API_KEY 필요. 로컬은 .env)
APPLY=1 CONCURRENCY=4 bin/rails "solar:extract[comorbidity]"
```

서버에서는 컨테이너 안에서 직접 실행합니다. `kamal app exec`는 셸을 거치지 않으므로 환경변수는 `env`로 줍니다(6.4 참고).

```bash
bin/kamal app exec --roles=web --reuse "env LIMIT=20 bin/rails 'solar:extract[comorbidity]'"
bin/kamal app exec --roles=web --reuse "env APPLY=1 MODEL=solar-mini-4-5-preview CONCURRENCY=4 bin/rails 'solar:extract[comorbidity]'"
```

- **환경변수**(코드 기준):

| 변수 | 기본 | 뜻 |
|---|---|---|
| `APPLY` | 없음(dry-run) | `1`일 때만 호출합니다. |
| `LIMIT` | 전체 | 아직 안 한 후보 중 앞 n건만 처리합니다. |
| `SCOPE` | `all` | `all`, `empty_rows`(추출 컬럼 `job_name`·`main_reasoning`·`work_relevance_eval`이 모두 빈 행), `disease_category=근골격계`, `case_nos=파일경로`(한 줄에 case_no 하나) |
| `CONCURRENCY` | 1 | 동시 호출 수. 1~8 범위로 맞춥니다. |
| `MODEL` | `SOLAR_MODEL` → `solar-mini4` | 모델 ID |
| `RPM` / `TPM` | 100 / 250000 | 로컬 요청 한도 제한기 값(Tier 0 기준). 계정 등급에 맞춰 낮게 줍니다. |
| `SOLAR_REASONING_EFFORT` | `none` | 요청의 `reasoning_effort`로 보냅니다. 빈 값이면 보내지 않습니다. |
| `OUT_DIR` | `storage/exports/solar/<과제>/` | 결과 폴더 |
| `SKIP_FAILED` | 꺼짐 | `1`이면 `failures.jsonl`에 있는 건을 건너뜁니다. |
| `PROGRESS_EVERY` | 50 | 진행 로그 간격(건) |
| `TOKENS_PER_CHAR`·`OUT_TOKENS`·`PRICE_IN`·`PRICE_OUT`·`LATENCY` | 0.6·300·0.10·0.40·4.0초 | 추정 전용. `OUT_TOKENS`는 제한기 예약에도 쓰입니다. 가격은 $/100만 토큰입니다. |

- **출력**: `OUT_DIR/results.jsonl`에 건마다 한 줄씩 씁니다. `status`는 `ok`(검증 통과) 또는 `invalid`(검증 실패, `validation_errors`에 사유)입니다. `OUT_DIR/failures.jsonl`에는 재시도를 소진했거나 되돌릴 수 없는 오류 건을 `error_class`와 고정 문구만으로 씁니다. 근거 문장(`evidence_quote`)은 검증 통과 여부와 상관없이 번호 형태가 가려지고 80자로 잘려 저장됩니다.
- **과제별 검증·출력 규칙**(p4/s3/v4, 정답 200건 시범 결과 반영). 결과 줄에는 `prompt_version`·`schema_version`과 함께 `validator_version`이 들어갑니다(프롬프트·스키마가 같아도 검증 규칙이나 결과 형식이 바뀌면 올립니다):
  - `comorbidity`: 값이 `미확인`이면 mention은 `언급없음`이고 근거 문장은 없어야 합니다. mention이 `있음`이면 값은 `미확인`·빈 배열이 아니고 근거 문장이 있어야 합니다. `없음`은 `비흡연`·`비음주`·빈 배열과만 짝입니다. 프롬프트는 근거가 값을 직접 뒷받침해야 하고(진단명 머리말·"건강보험 수진내역" 같은 일반 구절 금지), 오래된 검진 문진표는 현재 상태로 읽지 않으며, 약물 이름만으로 질환을 추정하지 않도록(보수적) 지시합니다. v3는 코드로도 막습니다. (1) 근거 문장에 값의 키워드가 하나도 없으면 invalid입니다: 흡연(흡연·담배·금연·개비·`N갑` 등), 음주(음주·술·주량·소주·맥주 등, "알콜성/알코올성"+질환명은 지우고 검사하므로 "알콜성간질환"만으로는 근거가 아님, "수술"의 술은 세지 않음), 기저질환(범주별 키워드, `comorbidities`는 근거가 목록 전체에 하나뿐이라 값에 든 범주 중 하나라도 맞으면 통과, `기타`는 일반 구절 검사만). 사전은 `Comorbidity`의 상수입니다. **v4에서 기저질환(comorbidities)의 키워드 부재는 invalid가 아니라 `output.review_flags`(`{rule: "evidence_keyword_missing", field, message}`, 항상 배열)로 낮췄습니다**: p3 정답 200건에서 퇴행성 TP 33건 중 26건이 invalid로 막혀 거르는 효과보다 과잉 차단이 컸습니다. 퇴행성 사전은 변성·stenosis·OA를 더해 넓혔습니다. 흡연·음주 키워드 검사는 그대로 invalid입니다. (2) "건강보험 수진내역"·"상세불명의"·"과거력" 같은 일반 머리말을 지우고 한글·숫자가 2자 미만이면 invalid입니다(실제 내용이 함께 있으면 통과). **p4(s3)부터 모델은 `source`를 내지 않습니다**(`comorbidities`·`smoking`·`alcohol`만). 결과의 `source`는 코드가 파생합니다(CODEBOOK 결정 2026-11-20): 기저질환이 비면 `언급없음`, 근거 문장이나 값 범주 키워드가 [의학적 소견]·[인정 사실]에 있으면 `사실 기록`, [위원회 판단]에만 있으면 `위원회 판단`. 간이 규칙이라 신청 상병명 키워드가 소견 절에 있으면 `사실 기록`으로 잘못 가를 수 있고, 근거를 못 찾으면 `사실 기록`으로 둡니다. 프롬프트는 신청 상병 제외, 퇴행성·기타·비만·뇌혈관 범주 정의를 코드북 문구로 구체화했습니다(합성 예시만 사용).
  - `prior_career`: 모델은 `mention`과 `careers[]`만 냅니다(`prior_career_months`는 스키마에서 뺐습니다). 개월 수는 검증 단계에서 코드가 `careers` 구간으로 계산해 결과에 넣습니다(양 끝 포함 월 수, 겹친 달은 한 번만, 시작·끝이 없는 구간이 하나라도 있으면 `null`, `mention=없음`이면 0, `언급없음`이면 `null`). 프롬프트는 현재 사업장 근무를 과거 경력에서 제외하고, "이전 근무경력: 무"면 `mention=없음`+빈 배열, 언급이 없으면 `언급없음`으로 하도록 지시합니다(가상 예시 포함). `mention=있음`인데 `careers`가 비거나, 그 밖의 mention인데 `careers`가 있으면 invalid입니다. `careers`는 최대 10개이며 넘으면 코드가 앞에서 10개만 남깁니다(Structured outputs의 `maxItems` 지원 여부를 문서에서 확인하지 못해 스키마에는 넣지 않았습니다). 프롬프트(p4)는 법인 전환·고용승계·상호/소속 변경·사업주 변경·재입사를 현 사업장으로 보고 현 사업장 직력만 있으면 `언급없음`을 쓰게 하며 합성 예시를 더했습니다. 월 미상 구간은 `start_ym`/`end_ym`에 `YYYY`만 받습니다. 개월 수는 월을 모르는 구간이 하나라도 있으면 `null`(보수적, 코드북과 같음)이고 구간은 `careers`에 남습니다. 모델이 판정서 표기(`2012.10`, `2012.10.05`, `2012/10`)를 옮기면 코드가 `YYYY-MM`으로 맞춥니다(일은 버림). 시작>끝 검사는 연만 있는 쪽을 시작은 1월, 끝은 12월로 보고 합니다. v3는 현 사업장 후처리를 더했고 v4는 `same_employer_marker`(근거 문장에 법인 전환·고용승계·상호/소속 변경·재입사 표지)를 review_flags에 더합니다: 종료 시점이 없고 근거가 진행 중 표현(현재·재직 중·진단일까지 등)이면 invalid, 어림짐작이 섞인 의심(입력이 밝힌 현 사업장 시작일 이후·겹침, 같은 업체 고용형태 변경 표지)은 `output.review_flags`(`{rule, career_indexes, message}` 배열, 항상 존재)에 남기고 invalid로 하지 않습니다. 입력 텍스트와 `careers`만 쓰며 DB의 다른 컬럼은 읽지 않습니다.
  - 출력 토큰 상한은 과제별입니다(`Tasks::Base#max_tokens`, 기본 1500, `prior_career` 3000). 실행기가 호출마다 `max_tokens`로 넘기고 클라이언트는 이 값을 생성자 값보다 우선합니다.
- **시범 결과 요약**(`solar-mini-4-5-preview`, 20건, 요약 수치만. 상세는 `storage/exports/solar/pilot/mini-4-5-preview-p2/REPORT.md`): p1은 comorbidity ok 18/invalid 2, prior_career ok 19/failed 1(출력 잘림), 개월 수 일치 1/19, 현 사업장을 이전 경력으로 넣은 건이 확인한 7건 중 3건, mention 있음 19/19였습니다. p2는 comorbidity ok 18/invalid 2, prior_career ok 17/invalid 3/failed 0이고 mention이 있음 14·언급없음 5·없음 1로 갈렸습니다. 현 사업장 혼입은 일부만 줄었습니다. p3(프롬프트 동일, 검증기 v3, 상세는 `.../mini-4-5-preview-p3/REPORT.md`)는 comorbidity ok 12/invalid 8, prior_career ok 17/invalid 3(review_flags 4개·2건)이며 p2 ok였던 comorbidity 6건이 invalid로 바뀌었고 확정 거짓양성은 0건이었습니다. 20건이라 통계적 결론은 아니었습니다.
- **정답 200건 결과**(`solar-mini-4-5-preview`, 잠정 정답, 채점 N=199, 신뢰 행 44건, 상세 `storage/exports/solar/pilot/mini-4-5-preview-p3-gold200/REPORT.md`와 `...-p4-gold200/REPORT.md`):

| 칸 | p3 전체 | p4 전체 | p3 신뢰 행 | p4 신뢰 행 |
|---|---|---|---|---|
| comorbidities 완전 일치 | 49.7% | 54.8% | 59.1% | 54.5% |
| preexisting_source | 53.8% | 73.4% | 63.6% | 70.5% |
| smoking / alcohol | 97.0% / 99.0% | 96.0% / 96.5% | 97.7% / 97.7% | 95.5% / 95.5% |
| prior_career mention | 87.4% | 89.9% | 68.2% | 77.3% |
| months 정확(null 포함) | 72.9% | 75.9% | 75.0% | 77.3% |
| careers 구간 수 | 67.3% | 67.8% | 72.7% | 77.3% |
| invalid 수(comorbidity / prior_career) | 78 / 20 | 46 / 9 | 21 / 3 | 9 / 3 |

  source가 코드 파생으로 가장 크게 좋아졌고 퇴행성 정밀도도 62%에서 84%로 올랐습니다. 현 사업장 혼입(`언급없음->있음` 21건에서 15건)과 기타·뇌혈관 재현율은 아직 낮고, 신뢰 행이 44건이라 몇 건 차이는 모델 변동일 수 있습니다. 모델은 Private Beta 무료 모델입니다. 운영 사용은 6.4 사용자 결정을 참고합니다.
- **동시 실행 방지**: `APPLY=1`은 `OUT_DIR/.lock`에 배타적 `flock`을 잡습니다. 같은 폴더에서 이미 실행 중이면 안내 문구와 함께 중단합니다(dry-run은 잡지 않음).
- **이어 받기**: 시작할 때 두 파일을 읽어 `results.jsonl`에 있는 건(`ok`·`invalid`)은 건너뜁니다. `invalid`도 다시 호출하지 않습니다. `failures.jsonl`에만 있는 건은 다시 시도하고, `SKIP_FAILED=1`이면 건너뜁니다. 중단되면 같은 명령을 다시 실행하면 됩니다.
- **중단 조건**(fail-fast): 아래 중 하나면 새 건을 시작하지 않고 멈춥니다.
  - 키 없음(`APPLY=1`일 때 rake가 `abort`), HTTP 401·403, 월 청구 한도 초과(`usage_limit_exceeded`)
  - 연속 20건 실패
  - `INT`·`TERM` 신호: 진행 중인 건만 마치고 저장합니다. 큐에 남은 건은 쓰지 않으므로 다시 실행하면 이어 받습니다.
  - 워커가 예기치 않게 죽으면(저장 실패 등) 중단하고 오류를 올립니다.
  - 그 밖의 오류: 429·5xx·408·타임아웃·네트워크 오류는 지수 백오프로 최대 5회 재시도합니다(429는 응답 헤더의 대기 시각을 그대로 따르고, 15분을 넘으면 일찍 재시도하지 않고 소진 처리합니다. 백오프 상한은 120초). 소진되면 `failures.jsonl`에 기록하고 계속합니다. 다른 4xx는 그 건만 실패로 기록합니다.
- **동시성과 시간 추정**: 요청 한도(TPM)는 요청이 겹칠 때만 병목이 됩니다. `CONCURRENCY=1`이면 요청이 하나씩 끝날 때까지 기다려 분당 약 15건이고, 61,815건은 약 69시간입니다(분당 약 6.8만 토큰, 250K TPM의 27%). 아래는 6.1 가정(요청당 입력 4,000 + 출력 500 = 4,500토큰, 지연 4초)으로 한 계산입니다. 추정이며 파일럿으로 교체합니다.

| CONCURRENCY | 지연 기준 처리량 | 실제 상한 | 전체 시간 |
|---|---|---|---|
| 1 | 15건/분 | 15건/분 | 약 69시간 |
| 4 | 60건/분 | 약 55건/분(TPM 250K ÷ 4,500) | 약 19시간 |
| 8 | 120건/분 | 약 55건/분(TPM이 먼저 막음) | 약 19시간 |

  - Tier 0(250K TPM)에서는 동시성 4 이상을 올려도 이득이 없습니다. 4 정도가 TPM 한도에 닿는 지점입니다.
  - Tier 1(500K TPM)이면 동시성 8에서 약 9시간, Legacy Tier(50K TPM)면 약 93시간입니다.
  - 제한기는 호출 전에 추정 토큰(입력 추정 + `OUT_TOKENS`)을 예약하므로 실제 처리량은 다를 수 있습니다.- **한도 준수**: 분당 요청·토큰 한도를 지킵니다. 429와 타임아웃은 backoff로 재시도하고 실패 건은 별도 파일에 기록합니다.
- **진행 로그**: 건수와 추정 남은 시간만 남기고 판정서 원문은 로그에 남기지 않습니다.
- **출력**: DB에 바로 쓰지 않고 `storage/exports/`(볼륨에 남고 gitignore) 아래 JSONL/CSV로 씁니다. 검토 뒤 별도 import 태스크·PR로 적재하고, 정규화·FTS rebuild 순서는 `CONTRIBUTING.md` 5.6을 따르며 먼저 `bin/rails db:backup`을 합니다.
- **실행 방법(분리 실행)**: `--reuse`(`docker exec`)는 SSH 세션에 묶여 끊기면 멈출 수 있으므로, 전체 실행은 `bin/kamal app exec --roles=web --detach "sh bin/solar_run.sh"`로 별도 컨테이너에 띄웁니다. 검증 상태: Kamal 2.12.0 소스로 `--detach`가 `docker run --detach`(`--rm`·`--restart` 없음)이고 이름이 `<service>-<role>-exec-<version>-<hex>`이며 role env 파일(비밀값)·볼륨이 붙고 `--reuse`와 함께 못 쓴다는 것까지 확인했습니다. 서버 실측 전이라 `LIMIT=20` 시험(로그·결과·`docker stop` 동작)으로 확인합니다. `bin/solar_run.sh`는 이미지에 들어가므로 배포 뒤에 쓸 수 있고, 배포 전에는 `/data/workercare/storage/solar_run.sh`로 올려 `sh /rails/storage/solar_run.sh`로 실행합니다(6.4).
- **차선**: `docker exec -d`(web 컨테이너 안 실행)도 SSH와는 분리되지만 배포·재시작 때 같이 멈추고 `docker stop`으로 끌 수 없습니다.
- **배포와 충돌**: 분리 실행한 별도 컨테이너는 `kamal deploy`가 멈추지 않지만 실행 중에는 배포하지 않습니다(6.4). 차선인 `docker exec -d`는 배포하면 끊깁니다. 끊기면 이어 받기로 재개합니다.
- **DB 부하**: SQLite는 읽기만 하므로 웹과 같이 돌려도 되지만 부하를 확인합니다.
- **운영 실행은 사용자가 직접 합니다.**

### 6.4 서버 대량 실행 준비 (초안)

실제 서버 실행·비밀값 설정·모델 선택은 **사용자가 직접 결정하고 실행**합니다. 이 절은 준비 절차와 추정입니다.

**모델 선택(사용자 결정)**
- **사용자 결정(2026-11-20): 운영 대량 추출 모델은 `solar-mini-4-5-preview`입니다.** 유료 모델(`solar-mini4`, `solar-pro4`)은 현재 키로 HTTP 403 `api_key_is_not_allowed`가 나와 쓸 수 없습니다.
- 위험을 알고 감수합니다. Private Beta 무료 모델이라 입력이 저장되고 학습·평가에 쓰일 수 있으며, 11/30에 끝나고 예고 없이 중단될 수 있습니다. 요청 한도(RPM·TPM)도 아직 확인하지 않았습니다. 보내는 것은 공개·비식별 판정서뿐이고 사용자 입력(단계별 사례 찾기 답, 검색어, 챗봇 발화)은 보내지 않습니다.
- 그래서 11/30 전에 끝나도록 바로 실행합니다. 중간에 중단되면 이어 받기로 남은 건을 유료 모델로 돌릴 수 있는 경우에만 돌리고, 결과 폴더(`OUT_DIR`)를 모델별로 나눕니다. 이어 받기는 같은 폴더 안에서만 건너뛰므로 나중에 결과를 합칠 때 건 중복을 확인합니다.
- 정확도: 6.2의 p4 정답 200건 결과(`solar-mini-4-5-preview` 기준)는 이 모델의 정확도입니다. 유료 모델의 정확도는 아직 재지 않았습니다.
- 한국 리전·약관 검토(제7·9·22·26조)와 비용 상한은 사용자가 정합니다.

**토큰·비용 추정(정답 200건 실측, p4)**
- 건당 평균: comorbidity 입력 3,316 + 출력 96, prior_career 입력 3,059 + 출력 236 토큰. 두 과제 합 입력 약 6,375 + 출력 약 332.
- 61,815건 x 2과제 = 입력 약 3.94억, 출력 약 2,050만 토큰. 정답 표본은 층화 표본이라 전체 평균과 다를 수 있습니다(`dry-run`의 추정과 대조).
- 비용: `solar-mini-4-5-preview`는 무료 베타라 실비는 0입니다. 아래 산식은 유료 모델 기준 참고값입니다. 산식: 비용 = 입력 토큰 x 입력 단가 + 출력 토큰 x 출력 단가. `solar-mini4`($0.10/$0.40 per 1M)는 39.4 + 8.2 = 약 $48, `solar-pro4`($0.30/$1.20)는 118 + 24.6 = 약 $143(두 과제 합, 단가는 4절 표 기준이며 실행 전 콘솔에서 확인).
- 시간: preview의 요청 한도는 확인되지 않았습니다. 아래는 4절 표 기준 참고 추정이고, dry-run과 소량 실행 실측으로 다시 잡습니다. Tier 0(250K TPM)이면 건당 약 3.4K 토큰이라 분당 약 73건(comorbidity) 또는 76건(prior_career), 과제당 약 14시간, 두 과제 약 28시간(동시성 4 안팎, 값은 실측 지연이 아니라 TPM 상한 기준). Tier 1(500K)이면 절반 정도입니다.

**절차**
> 주의: `kamal app exec`는 컨테이너 안에서 셸을 거치지 않으므로 환경변수는 `env VAR=값 명령` 형태로 준다(`VAR=값 명령`은 exit 127).

1. 키: 코드가 읽는 환경변수는 `UPSTAGE_API_KEY`입니다(`SolarExtraction::Client`). `.kamal/secrets`에 참조 한 줄을 추가하고 `config/deploy.yml`의 `env.secret`에 `UPSTAGE_API_KEY`를 추가한 뒤 배포하는 일은 사용자가 직접 합니다(6.3). 모델은 `env.clear`에 `SOLAR_MODEL: solar-mini-4-5-preview`로 두거나 실행 때마다 `MODEL=solar-mini-4-5-preview`로 줍니다. 11/30 뒤에는 이 값을 바꿔야 합니다.
2. dry-run(호출 없음, 키 불필요): `bin/kamal app exec --roles=web --reuse "bin/rails 'solar:extract[comorbidity]'"`. 건수·토큰·비용·시간 추정을 확인합니다. 이전 `mcp` 컨테이너가 남아 있으면 `--roles=web`을 유지합니다(AGENTS.md).
3. 소량 APPLY: 아래 명령으로 실행하고, 결과를 가져와 검토합니다(아래). `RPM`·`TPM`에는 계정 한도 숫자를 넣습니다.
   ```bash
   bin/kamal app exec --roles=web --reuse "env APPLY=1 MODEL=solar-mini-4-5-preview LIMIT=300 CONCURRENCY=2 RPM=<계정 한도> TPM=<계정 한도> bin/rails 'solar:extract[comorbidity]'"
   ```
4. 전체(분리 실행): `bin/solar_run.sh`가 comorbidity, prior_career를 **순차**로 돌립니다(같은 키 한도를 공유해 병렬이 이득이 없고 제한기가 프로세스별이라 한도를 넘기기 쉽습니다). 기본값은 `APPLY=1`, `MODEL=solar-mini-4-5-preview`, `CONCURRENCY=4`이고 `LIMIT`·`RPM`·`TPM`·`OUT_DIR`(주면 `<OUT_DIR>/<과제>`)은 `env`로 줍니다. 로그는 볼륨의 `exports/solar/run.log`(시작·끝 시각, 과제, 모델, 종료 코드, rails 출력)에 쌓이고, 과제가 비정상 종료하면 다음 과제를 시작하지 않습니다.
   ```bash
   # 시험(배포 뒤. 서버 실측 확인): 로그·결과·중단 동작을 봅니다
   bin/kamal app exec --roles=web --detach "env LIMIT=20 RPM=<계정 한도> TPM=<계정 한도> sh bin/solar_run.sh comorbidity"
   # 전체
   bin/kamal app exec --roles=web --detach "env RPM=<계정 한도> TPM=<계정 한도> sh bin/solar_run.sh"
   # 이미지에 아직 없으면(배포 전): scp bin/solar_run.sh web01.workercare:/data/workercare/storage/solar_run.sh 뒤
   bin/kamal app exec --roles=web --detach "sh /rails/storage/solar_run.sh"
   ```
   `--reuse`는 쓰지 않고 `--roles=web`은 유지합니다. 이미지 태그는 `--version` 미지정 시 서버의 최신 이미지입니다.
   - 진행 확인: `ssh web01.workercare "tail -n 5 /data/workercare/storage/exports/solar/run.log"`, `ssh web01.workercare "wc -l /data/workercare/storage/exports/solar/*/results.jsonl"`, `ssh web01.workercare "docker ps --filter name=exec --format '{{.Names}} {{.Status}}'"`. 중단 사유는 `grep "중단 사유" run.log`로 봅니다.
   - 중단: `ssh web01.workercare "docker stop -t 240 <이름>"`. 스크립트가 TERM을 rails에 넘겨 진행 중인 건만 마치고 멈추고 이후 과제는 시작하지 않습니다(요청당 최대 180초라 `-t`를 넉넉히).
   - 결과 가져오기: 아래 scp. 끝난 컨테이너는 `docker rm <이름>`으로 지웁니다.
   - 주의: 실행 중에는 배포하지 않습니다(별도 컨테이너라 작업은 살아 있으나 서버 메모리가 겹치고, `.kamal/hooks/post-deploy`의 `docker system prune -f`가 종료된 컨테이너와 그 docker logs를 지웁니다. 로그는 `run.log`에서 봅니다). 11/30 안에 끝내려면 배포를 동결합니다.
5. 이어 받기: 컨테이너가 죽었거나(중단·한도 초과) 서버가 재부팅됐으면(`--restart`가 없어 자동으로 돌아오지 않음, 가끔 `docker ps` 확인) 같은 4번 명령을 다시 실행합니다. `results.jsonl`에 있는 건은 건너뛰고 `.lock`은 프로세스와 함께 풀리므로 지울 필요가 없습니다. 모델을 바꿔 이어 받을 때는 `OUT_DIR`을 따로 줍니다(위 모델 선택 참고). rake는 중단 사유(한도 초과·인증 오류 등)로 멈추면 종료 코드 2로 끝나고(신호 중단은 0), 그러면 `bin/solar_run.sh`는 다음 과제를 시작하지 않습니다. 사유는 `run.log`의 "중단 사유" 줄에서 봅니다.
6. 동시성·한도: `CONCURRENCY`(1~8)와 `RPM`/`TPM`(로컬 제한기)을 계정 등급에 맞춥니다. 429는 응답 헤더의 대기 시각을 따르고 한도 초과·401/403은 즉시 중단합니다(6.2 중단 조건).

**결과 위치와 검토**
- 컨테이너 안 `/rails/storage/exports/solar/<과제>/{results,failures}.jsonl`(볼륨 `/data/workercare/storage`가 호스트에 있으므로 호스트 경로는 `/data/workercare/storage/exports/solar/`). `OUT_DIR`로 바꿀 수 있습니다.
- 로컬로 가져오기: `scp web01.workercare:/data/workercare/storage/exports/solar/<과제>/results.jsonl <로컬 storage/exports/solar/server/<과제>/>`. 결과는 판정서와 같은 취급이라 저장소·채팅·외부에 올리지 않습니다.
- 검토: `status` 분포, `validation_errors` 상위 사유, `review_flags`를 보고 표본을 정답과 대조합니다(정답 200건에 대한 비교 스크립트 방식). 이 단계에서 정확도가 기준 아래면 프롬프트를 고치고 새 버전으로 다시 돌립니다. 버전이 다른 결과를 한 파일에 섞지 않도록 `OUT_DIR`을 버전별로 나눕니다.
- DB 적재는 별도 단계입니다: 검토를 마친 뒤 import 태스크·PR로 적재하고 먼저 `bin/rails db:backup`을 합니다(`CONTRIBUTING.md` 5.6). 이 추출 태스크는 DB에 쓰지 않습니다.

### 6.3 API 키

- 로컬은 `.env`의 `UPSTAGE_API_KEY`를 씁니다. `dotenv`는 development·test 그룹에만 있습니다. `.env.example`에 빈 항목이 있으며, 값은 문서·커밋에 적지 않습니다.
- 서버(Kamal secrets)는 **아직 적용하지 않았습니다**(이 PR은 `config/deploy.yml`을 바꾸지 않습니다). 아래 두 가지를 **함께** 합니다.
  1. 사용자가 `.kamal/secrets`에 `UPSTAGE_API_KEY=$UPSTAGE_API_KEY` 참조 한 줄을 직접 추가합니다.
  2. `config/deploy.yml`의 `env.secret`에 `UPSTAGE_API_KEY`를 추가합니다.
  한쪽만 하면 `kamal deploy`가 누락된 secret 때문에 실패합니다.
- 키가 없으면 `APPLY=1` 실행은 시작하지 않고 멈춥니다(dry-run은 키가 필요 없습니다).

## 7. 단계·마일스톤

| 단계 | 내용 | 산출물 |
|---|---|---|
| 0 | 약관·데이터 이용 조건 읽기, 팀 합의 | 합의 기록 |
| 1 | 코드북 초안, 정답 200건 라벨링(2.1 항목의 라벨 포함, 건강검진·화학물질은 해당 건이 적으니 따로 층화) | 라벨 파일(로컬) |
| 2 | 로컬 모델·프롬프트·스키마 비교, 평균 토큰·비용 추정. 2.1 항목은 기저질환·과거 근무경력부터 시험하고 화학물질 스키마는 재설계 | 비교 결과 |
| 3 | rake 태스크 구현 PR(dry-run, 이어 받기, 재시도) | PR. **구현됨(이 PR)** |
| 4 | 소규모 서버 시험(수백 건) | 출력 JSONL 검토 |
| 5 | 서버 전체 실행(과제 C → B → A 순 제안) | `storage/exports/` 결과 |
| 6 | 검토 후 import 태스크 PR, 백업·FTS rebuild | 적재 |
| 7 | 통계 화면·`/about` 반영(과제 A), 품질 점검(과제 D) | 화면 |

## 8. 위험·미결정

- 정확도 기준 값(예: 항목별 정확도, 환각 허용치)을 정해야 합니다.
- 불인정 사유 코드북을 확정해야 하고, 법률·의료 전문가 검토가 필요한지 정해야 합니다.
- 비용 상한(전체 실행 한도)을 정해야 합니다.
- 4.5 Preview 베타가 11/30에 끝납니다. 이후 정식 모델이나 `solar-mini4`로 재시험합니다.
- 약관 검토(제7·9·22·26조)와 한국 리전(Closed Beta) 필요 여부를 정해야 합니다.
- 판정서 본문을 외부로 보내는 것에 대한 팀 합의 여부(이 문서는 합의를 전제로 한 계획입니다).
- 비식별 한계: 판정서에 남은 이름·주소가 외부로 나갈 수 있습니다. 표본 점검으로 위험을 확인합니다.
- LLM 추출은 틀릴 수 있습니다. 화면에는 추출값임을 표시하고 원문 링크를 함께 둡니다.
- 2.1 항목의 언급률·예상 채움률은 키워드 기준 추정입니다. 정답 200건 라벨로 검증하기 전에는 확정치로 쓰지 않습니다.
- 건강검진 수치는 민감정보입니다. 범주 플래그만 저장하고 원 수치는 로컬 분석용으로 한정하며, 웹·챗봇에는 노출하지 않습니다(함정 8).
- 기저질환·건강검진·화학물질·작업환경 통계는 언급 빈도입니다. 인과나 승인 가능성으로 읽히지 않게 표기하고, 질환군 NULL 6,290건의 성격과 연도별 양식 차이는 확인이 필요합니다.
