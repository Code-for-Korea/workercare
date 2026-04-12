# MCP 기반 업무상질병 판정서 상담 챗봇 구상 (개선안 v2)

> **핵심 철학**: 이 시스템은 단순한 "검색 챗봇"이 아니라 **"판정 근거를 설명하는 엔진"**이다.
> **설계 완성도**: 8.5/10 | **구현 가능성**: 높음 | **차별성**: 명확함

## 개요

**아키텍처 전제**: MCP 서버는 **stateless**이며 LLM을 직접 호출하지 않습니다. 사용자는 자신의 AI 클라이언트(Claude Desktop, Cursor, 기타 MCP 지원 클라이언트)에서 `https://example.com/mcp` URL을 연결하여 사용합니다.

사용자가 자신의 업무상 질병 신청에 대해 자연어로 질문하면, **사용자의 AI 클라이언트**가 MCP 서버의 Tool/Prompt를 호출하고, 서버는 **데이터베이스 직접 조회 및 통계 집계 결과**를 반환합니다. LLM 처리(자연어 이해, 문장 생성, 대화 맥락 관리)는 전적으로 **클라이언트 측**에서 수행합니다.

## 사용자 시나리오 (5단계 + 대화 상태)

> **전제**: 대화 상태(슬롯) 관리는 **사용자의 AI 클라이언트**에서 수행합니다. MCP 서버는 stateless이며 세션을 저장하지 않습니다.

### 대화 상태 (Slot-based Information Collection)

사용자의 AI 클라이언트가 다음 슬롯을 유지하며, 빈 슬롯이 있으면 먼저 정보를 수집합니다:

```json
{
  "symptom": "손목 저림과 통증",
  "diagnosis": null,
  "work_type": "사무실 컴퓨터 작업",
  "work_duration": "8시간/일, 2년",
  "medical_evidence": ["정형외과 진단서"],
  "body_part_guess": "hand",
  "disease_category_guess": "musculoskeletal"
}
```

**개선된 질문 방식** (클라이언트가 생성):
- 기존: "진단명이 있으신가요?"
- 개선: "판단에 필요한 정보가 부족합니다. 다음을 알려주시면 더 정확한 분석이 가능합니다: ① 진단명 ② 증상 발생 시점 ③ 하루 작업 시간"

### 단계 1: 증상 및 업무 환경 수집
- 사용자: "사무실에서 오랫동안 컴퓨터 작업을 하다가 손목이 아픈데 산재 신청이 가능할까요?"
- **클라이언트**: 슬롯에 정보 저장 → `extract_search_keywords` MCP Prompt 실행 → `symptom`, `work_type`, `body_part_guess`, `disease_category_guess` 채움
- **클라이언트**: "손목 관련 근골격계 질환 사례를 검색할까요? 추가로 진단명이나 하루 작업 시간을 알려주시면 더 정확한 분석이 가능합니다."

### 단계 2: 1차 사례 검색 및 요약
- MCP Tool `search_disease_cases` 실행 (search_in: `[application_content, applicant_claim]`)
- **클라이언트**: **"유사한 사례 42건을 찾았습니다. (인정 28건, 불인정 10건, 일부인정 3건, 정정인정 1건) 주로 다음과 같은 내용들이 있었어요..."** (유사 사례 수 명시)

### 단계 3: 추가 정보 수집 및 보충 검색
- **클라이언트**: "판단에 필요한 정보가 부족합니다: ① 진단명 ② 증상 발생 시점 ③ 하루 작업 시간"
- 사용자가 추가 정보 제공 → 슬롯 업데이트 (클라이언트에서 관리)
- MCP Tool `search_disease_cases` 재실행 (search_in: +[medical_records, recognized_facts])

### 단계 4: 종합 판단 및 인정/불인정 차이점 분석
- MCP Tool `compare_approval_factors` 실행
- **클라이언트가 Tool 결과를 바탕으로 답변 생성**:
  - "인정 사례 28건(66.7%) vs 불인정 사례 10건(23.8%), 일부인정 3건(7.1%), 정정인정 1건(2.4%)"
  - "인정 사례 공통점: 근전도 검사 양성률 85%, 업무 시작 6개월 이내 발병 70%"
  - "불인정 사례 공통점: 사전 질환력 60%, 업무 외 원인 제기 40%"

### 단계 5: 인정을 위한 보완 방안 제시 (불인정 시 대응)
- MCP Tool `suggest_evidence` 실행 (룰 기반)
- **클라이언트가 Tool 결과를 바탕으로 UX 흐름 생성**:
  1. **현재 상태 판단**: "현재 상황에서 불인정 가능성이 높습니다(23.8% 불인정 사례와 유사)."
  2. **그 이유 설명**: "주요 이유는 ① 객관적 검사 부재 ② 업무 연관성 입증 미흡"
  3. **보완 방법 제시**: "다음 자료를 보완하면 인정받을 가능성이 높아집니다..."

---

## MCP 컴포넌트 설계 (개선 구조)

> **서버 역할**: DB 조회, 통계 집계, 룰 기반 데이터 제공만 수행. **LLM 호출은 없음**.

```
search → 데이터 (DB 직접 조회)
compare → 통계 기반 분석 (서버) → 클라이언트가 LLM으로 설명 생성
suggest → 룰 기반 데이터 제공 (서버) → 클라이언트가 LLM으로 맞춤 설명
explain → 템플릿 기반 구조화 (MCP Prompt) → 클라이언트의 LLM이 문장 다듬기
```

**데이터 흐름**:
- **서버 → 클라이언트**: Tool 실행 결과 (JSON, 마크다운, 템플릿)
- **클라이언트 → 서버**: Tool 호출 파라미터
- **클라이언트 내부**: 슬롯 관리, LLM 호출, 문장 생성, 대화 맥락 유지

### 1. MCP Tool: `search_disease_cases`

**목적**: 데이터베이스에서 판정서 사례를 단계적으로 검색

**입력 파라미터**:
```json
{
  "q": "사용자 질문에서 추출한 자연어 검색어",
  "search_in": ["application_content", "applicant_claim"],
  "disease_category": ["musculoskeletal"],
  "body_part": ["hand"],
  "decided_on_from": "2020-01-01",
  "decided_on_to": "2025-12-31",
  "limit": 10
}
```

**출력**:
```json
{
  "error": null,
  "data": {
    "total_count": 42,
    "confidence_score": 0.82,
    "confidence_reason": "유사 사례 42건 (동일 신체부위, 유사 업무, 유사 증상)",
    "cases": [
      {
        "case_no": "2023-001234",
        "disease_name": "손목터널증후군",
        "result": "approved",
        "result_label": "인정",
        "year": 2023,
        "summary": "신청인 주장 요약...",
        "key_facts": "인정사실 핵심...",
        "decision_excerpt": "위원회 판단 일부...",
        "match_reason": ["동일 신체부위", "유사 업무", "유사 증상"]
      }
    ],
    "statistics": {
      "approved": 28,
      "rejected": 10,
      "partially_approved": 3,
      "revised_approved": 1,
      "total": 42,
      "approval_rate": "66.7%",
      "rejection_rate": "23.8%",
      "substantive_approval_rate": "69.0%",
      "strict_approval_rate": "66.7%"
    },
    "used_fallback": false
  }
}
```

**구현 방식**:
- `app/mcp/tools/search_disease_cases_tool.rb` 생성
- `DiseaseCase.search(params)` 호출 시 **반환값은 `[scope, fallback]` 튜플**이므로 반드시 구조 분해: `scope, fallback = DiseaseCase.search(params)`
- `fallback` 값을 응답에 포함하여 클라이언트가 FTS 검색 실패 시 substring 검색이 사용되었음을 인지할 수 있게 함
- 입력 파라미터를 `DiseaseCase.search()`가 기대하는 평면 구조(`q`, `result`, `disease_category`, `body_part`, `decided_on_from`, `decided_on_to`)로 전달
- `search_in` 파라미터는 `DiseaseCases::Searchable::SEARCHABLE_COLUMNS` 중 선택하여 `params[:search_in]`로 전달
- `statistics`는 `result` 필터를 제외한 동일 조건(q + 질병/신체부위/날짜 필터)의 전체 결과를 `group(:result).count`로 집계하여 제공
- **승인률 계산 기준**:
  - `strict_approval_rate = approved_count / total_count` (전체 결과를 분모로 사용)
  - `substantive_approval_rate = (approved_count + partially_approved_count + revised_approved_count) / total_count` (실질 인정률)
  - `rejection_rate = rejected_count / total_count`
- **limit 적용 규칙**: `limit`는 `cases` 배열(상세 사례 목록)에만 적용. `statistics` 집계 및 `total_count`에는 **미적용** — 전체 통계 정확성 유지. 예: `limit: 10`이면 `cases`는 10건만 반환하지만, `statistics`는 조건에 맞는 전체 42건 기준으로 집계.
- fallback 발생 시: `statistics`는 fallback 결과를 기준으로 집계하며, `used_fallback: true`로 표시하여 클라이언트가 인지할 수 있게 함
- **신뢰도 점수**: `confidence_score`는 검색 조건 일치도(질병 카테고리, 신체부위, 검색어 중복률)를 0~1 사이로 계산. `confidence_reason`은 점수 산출 근거를 자연어로 설명
- **매칭 이유**: 각 사례의 `match_reason`은 질병명/신체부위/업무환경/증상 중 일치하는 항목을 태그로 반환
- 단계별로 다른 컬럼에 검색이 필요하면 클라이언트가 `search_in` 값을 단계에 맞게 변경하여 호출:
  - 1차: `["application_content", "applicant_claim"]`
  - 2차: `["application_content", "applicant_claim", "medical_records", "recognized_facts"]`
  - 3차: `["application_content", "applicant_claim", "medical_records", "recognized_facts", "committee_decision"]`

---

### 2. MCP Tool: `compare_approval_factors` (개선: 3단계 상태 분류 + 통계 기반)

**목적**: 인정 사례와 불인정 사례를 **통계적으로 비교**하여 승인/거절의 핵심 요인 도출. 정규식은 단순 키워드 매칭이 아닌 **상태 분류** 수준으로 설계.

**입력 파라미터**:
```json
{
  "disease_name": "손목터널증후군",
  "disease_category": "musculoskeletal",
  "body_part": "hand",
  "year_range": [2020, 2025]
}
```

**출력**:
```json
{
  "error": null,
  "data": {
    "statistics": {
      "approved_count": 28,
      "rejected_count": 10,
      "partially_approved_count": 3,
      "revised_approved_count": 1,
      "approval_rate": "66.7%",
      "rejection_rate": "23.8%"
    },
    "approved_common_patterns": {
      "medical_evidence": "근전도 검사 양성률 85%",
      "work_relation": "업무 시작 후 6개월 이내 발병 70%",
      "objective_findings": "객관적 검사 이상 90%"
    },
    "rejected_common_patterns": {
      "medical_evidence": "사전 질환력 존재 60%",
      "work_relation": "업무 외 원인 제기 40%",
      "objective_findings": "객관적 검사 정상 또는 경미 55%"
    },
    "key_differences": [
      {
        "factor": "객관적 검사 결과",
        "approved": "양성률 85% (근전도, MRI 등)",
        "rejected": "정상/경미 55%, 사전 질환 60%"
      }
    ],
    "detailed_evidence_stats": {
      "emg": {
        "positive": 18,
        "negative": 12,
        "not_performed": 7,
        "unknown": 5
      }
    },
    "llm_explanation": null
  }
}
```

**구현 방식**:
- `app/mcp/tools/compare_approval_factors_tool.rb` 생성
- **1단계: 통계 집계 (Ruby/DB)**:
  - 같은 질병명/신체부위로 인정/불인정 사례를 각각 검색 (`result: "approved"` / `result: "rejected"`)
  - `group(:result).count`로 인정/불인정 비율 계산
- **2단계: 상태 분류 기반 패턴 추출 (Ruby/정규식)**:
  - 단순 키워드 매칭이 아닌 **3단계 판단 구조** 적용: 키워드 탐지 → 부정어 스코프 확인 → 상태 분류
  - `evidence_rules.yml`의 각 질병 카테고리 하위에 `extraction_rules` 정의. 예시:
    ```yaml
    musculoskeletal:
      extraction_rules:
        emg:
          keywords: [/근전도/, /EMG/, /NCS/]
          positive: [/양성/, /이상 소견/, /이상 있음/, /신경 압박/]
          negative: [/정상/, /이상 없음/, /소견 없음/, /특이사항 없음/]
          not_performed: [/시행 안함/, /미실시/, /검사 안함/, /실시하지 않음/]
        mri:
          keywords: [/MRI/]
          positive: [/디스크/, /탈출/, /협착/]
          negative: [/정상/, /이상 없음/]
    ```
  - **핵심 함수** (`extract_status`):
    ```ruby
    def extract_status(text, rule)
      return nil unless rule[:keywords].any? { |k| text.match(k) }
      context = extract_context(text, Regexp.union(rule[:keywords]), window: 30)
      return :not_performed if match_any?(context, rule[:not_performed])
      return :positive if match_any?(context, rule[:positive])
      return :negative if match_any?(context, rule[:negative])
      :unknown
    end
    ```
  - **컨텍스트 추출** (`extract_context`): 키워드 주변 ±30자만 분석하여 노이즈 제거
    ```ruby
    def extract_context(text, keyword_regex, window: 30)
      match = text.match(keyword_regex)
      return text unless match
      start = [match.begin(0) - window, 0].max
      ending = [match.end(0) + window, text.length].min
      text[start...ending]
    end
    ```
  - **부정어 스코프 처리**: 문장 단위 분리 (`split(/[.!?]/))` 후 키워드가 포함된 문장만 분석. 동일 문장 내 부정어와 키워드 거리가 임계값 이내이면 `:negative`로 분류
  - **통계 집계 방식**: `approved`/`rejected` 각각에 대해 상태별 카운트 반환 (예: `emg_positive`, `emg_negative`, `emg_not_performed`, `emg_unknown`)
  - **반드시 피할 것**: `text.include?("근전도")` 같은 단순 포함 검사 — "근전도 검사 이상 없음"도 "검사 있음"으로 잡혀 통계 왜곡 발생
- **클라이언트 활용 가이드**:
  - `llm_explanation` 필드는 서버가 `null`로 반환하며, **클라이언트 LLM이 채워야 할 자리**입니다. 클라이언트는 위의 `statistics`/`key_differences` 데이터를 참고하여 자연어 설명을 생성합니다
  - 서버는 통계/패턴 분석만 제공하며, 문장 생성은 클라이언트 측에서 수행
  - 원문 분석이 필요한 경우 `committee_decision` 원문을 truncate하여 제공 (클라이언트가 추가 분석 가능)

---

### 3. MCP Tool: `suggest_evidence` (개선: 룰 기반 + LLM 보조)

**목적**: 불인정 사례를 분석하여 인정받기 위해 필요한 추가 증거 자료 제안. **룰 기반으로 필수 증거를 먼저 제시하고, LLM은 맞춤형 설명을 보조**합니다.

**룰 기반 증거 데이터베이스** (`config/evidence_rules.yml`):
```yaml
# evidence_rules.yml
# last_updated: 2026-04-22
# 목적: 질병 카테고리별 산재 인정에 필요한 증거 자료 정의

musculoskeletal:
  description: "근골격계 질환 (손목터널증후군, 디스크 등)"

  required:
    - type: "객관적 검사 (EMG/NCS, MRI, X-ray)"
      key: "objective_test"
      rationale: "객관적 검사에서 이상 소견은 업무상 질병 인정의 핵심 근거"
      where_to_get: "정형외과 또는 신경과 (산재 지정병원 권장)"
      notes:
        - "근전도 검사(EMG/NCS)는 손목터널증후군 필수"
        - "MRI는 디스크 질환에서 중요"

    - type: "요양급여신청소견서"
      key: "medical_opinion"
      rationale: "업무와 질병의 인과관계를 의학적으로 입증하는 필수 문서"
      where_to_get: "산재 지정병원 주치의 작성"

  optional:
    - type: "업무 환경 자료 (작업 시간, 반복 동작)"
      key: "workload_proof"
      importance: "high"
      rationale: "반복 작업 및 과부하를 객관적으로 입증"
      where_to_get: "본인 기록 또는 사업주 자료"

    - type: "동료 진술서"
      key: "coworker_statement"
      importance: "medium"
      rationale: "실제 업무 강도 및 환경 보완 증거"
      where_to_get: "동료 서면 진술"

    - type: "과거 병력 자료"
      key: "medical_history"
      importance: "medium"
      rationale: "사전 질환 여부 판단 (불인정 방어용)"
      where_to_get: "국민건강보험공단"

  risk_factors:
    - "사전 동일 부위 질환"
    - "업무 외 활동 (게임, 운동 등)"
    - "객관적 검사 이상 없음"

  strong_approval_signals:
    - "근전도 검사 양성"
    - "업무 시작 후 단기간 내 발병"
    - "반복 작업 6시간 이상/일"

cardiovascular:
  description: "심혈관 질환 (심근경색, 뇌졸중 등)"

  required:
    - type: "심전도 및 심장초음파 검사"
      key: "cardio_test"
      rationale: "심혈관 질환의 객관적 진단 필수"
      where_to_get: "내과 또는 심장내과"

    - type: "발병 전 업무 기록 (과로, 스트레스)"
      key: "overwork_proof"
      rationale: "과로 및 스트레스와 질병 간 인과관계 입증"
      where_to_get: "근무기록, 초과근무 기록"

  optional:
    - type: "근무시간 기록 (주 52시간 초과 여부)"
      key: "work_hours"
      importance: "high"
      rationale: "과로 기준 판단 핵심 자료"

    - type: "스트레스 요인 자료"
      key: "stress_factor"
      importance: "medium"
      rationale: "업무상 정신적 부담 입증"

  risk_factors:
    - "고혈압, 당뇨 등 기저질환"
    - "흡연, 음주"
    - "업무 외 스트레스"

  strong_approval_signals:
    - "발병 직전 과로 (주 60시간 이상)"
    - "급격한 업무 증가"
    - "야간/교대 근무 지속"
```

**입력 파라미터**:
```json
{
  "user_symptoms": "손목 저림과 통증",
  "user_work_environment": "사무실, 하루 8시간 컴퓨터 작업",
  "current_evidence": ["정형외과 진단서"],
  "rejected_case_nos": ["2023-000123", "2022-000987"],
  "disease_category": "musculoskeletal"
}
```

**출력**:
```json
{
  "error": null,
  "data": {
    "missing_evidence": [
      {
        "type": "근전도 검사 (EMG/NCS)",
        "importance": "필수",
        "rationale": "근골격계 질환 인정의 85%가 근전도 검사 양성 소견을 보유",
        "where_to_get": "신경과 또는 정형외과 (산재 지정병원 권장)",
        "estimated_time": "1주 내",
        "estimated_cost": "건강보험 적용 시 5~10만원"
      },
      {
        "type": "요양급여신청소견서",
        "importance": "필수",
        "rationale": "근로복지공단 제출 필수 서류",
        "where_to_get": "산재 지정병원 주치의 작성 (병원 원무과에서 대행 요청 가능)",
        "estimated_time": "진료 시 즉시",
        "estimated_cost": "무료"
      }
    ],
    "recommended_cases": [
      {
        "case_no": "2022-000987",
        "title": "초기 불인정 후 재신청 인정 사례",
        "key_lesson": "추가 근전도 검사와 동료 증언으로 인정 전환"
      }
    ],
    "next_steps": [
      { "action": "산재 지정병원 방문 → 원무과에 최초요양급여신청 대행 요청", "deadline": "즉시" },
      { "action": "근전도 검사(EMG/NCS) 실시 및 결과 보관", "deadline": "1주 내" },
      { "action": "업무 내 키보드/마우스 사용 시간, 작업 강도 일지 작성", "deadline": "1주 내" },
      { "action": "동료 2명 이상의 업무 환경 증언 확보 (서면 또는 녹취)", "deadline": "2주 내" },
      { "action": "근로복지공단 관할 지사에 서류 제출 (사업주 날인 불필요)", "deadline": "준비 완료 후" }
    ],
    "legal_basis": [
      "산업재해보상보험법 제37조: 업무와 재해 사이의 상당인과관계 필요",
      "산업재해보상보험법 제41조: 산재보험 의료기관의 요양급여신청 대행 가능"
    ],
    "llm_tailored_advice": null
  }
}
```

**구현 방식**:
- `app/mcp/tools/suggest_evidence_tool.rb` 생성
- **1단계: 룰 기반 필수 증거 제시 (Ruby/YAML)**:
  - `disease_category`에 해당하는 `evidence_rules.yml`의 `required`/`optional` 목록 반환
  - `current_evidence`와 대조하여 누락된 증거만 필터링 (YAML의 `key` 필드로 대조)
  - `rejected_case_nos`로 DB에서 불인정 사례 조회하여 '부족하다', '미흡하다' 키워드 빈도 확인 (Ruby 정규식)
- **recommended_cases 생성 방법 (Ruby/DB)**:
  - `rejected_case_nos` 중 `result: "revised_approved"` 또는 동일 질병명/신체부위로 나중에 `result: "approved"`로 변경된 사례를 DB에서 조회
  - `key_lesson` 필드: `committee_decision` 원문에서 '인정', '전환', '보완', '재신청' 키워드가 포함된 문장을 정규식으로 추출하여 최대 100자로 truncate
  - `title` 필드: "초기 불인정 후 [전환_방법] 인정 사례" 형태로 자동 생성 (예: `committee_decision`에서 '근전도 검사' + '동료 증언' 키워드 발견 시 "추가 근전도 검사와 동료 증언으로 인정 전환")
  - 불인정 사례 중 나중에 인정된 기록이 없으면 `recommended_cases: []` (빈 배열) 반환
- **클라이언트 활용 가이드 (LLM 맞춤형 설명)**:
  - 클라이언트의 LLM이 룰 기반 결과와 사용자 증상/업무환경을 Prompt에 전달하여 맞춤형 조언 생성
  - 서버는 `missing_evidence`, `next_steps`, `legal_basis` 등 구조화된 데이터만 제공하며, 문장 생성은 클라이언트 측에서 수행

---

### 4. MCP Tool: `get_procedure_guide`

**목적**: 사용자가 신청 절차, 필요 서류, 불인정 시 대응 방법 등을 직접 물어볼 때 공식 절차 안내

**입력 파라미터**:
```json
{
  "topic": "application | required_documents | rejection_appeal | compensation_types | timeline",
  "user_context": {
    "disease_name": "손목터널증후군",
    "body_part": "hand",
    "work_environment": "사무실, 컴퓨터 작업"
  }
}
```

**출력**:
```json
{
  "error": null,
  "data": "## 신청 절차\n\n1. 산재 지정병원 방문 → 원무과에서 최초요양급여신청 대행 요청\n2. 서류 작성: 최초요양신청서 — 재해 경위를 6하 원칙에 따라 상세히 기재\n3. 근로복지공단 제출: 관할 지역본부 또는 지사\n4. 업무상질병판정위원회 심의 (질병의 경우)\n5. 처리 결과 통보\n\n⚠️ 본 안내는 참고용이며, 최종 판단은 상담사/법원이 합니다."
}
```

**구현 방식**:
- `app/mcp/tools/get_procedure_guide_tool.rb` 생성
- `config/locales/procedure_guides.yml`에 절차 데이터 저장
- **YAML 관리 규칙**:
  - 파일 상단에 `# last_updated: 2026-04-21, source: https://www.easylaw.go.kr/CSP/CnpClsMainBtr.laf?csmSeq=570` 주석 필수
  - 법 개정 시 해당 주석 날짜와 출처를 갱신하여 최신성 추적
  - 법 조항 번호 변경 시 버전 관리(git diff)로 변경 이력 추적

---

### 5. MCP Prompt: `explain_determination` (개선: 템플릿 기반 + LLM 문장 다듬기)

**목적**: 검색된 사례들을 **템플릿 기반으로 구조화**하여 사용자에게 이해하기 쉽게 설명. LLM은 템플릿의 빈칸을 채우는 역할만 수행.

**템플릿 구조**:
```markdown
## 📊 유사 사례 결과
- 총 {total_count}건 검색
  - 인정: {approved_count}건 ({approval_rate})
  - 불인정: {rejected_count}건 ({rejection_rate})
  - 일부인정: {partially_approved_count}건
  - 정정인정: {revised_approved_count}건

## 🔍 주요 차이점
{llm_key_differences_summary}

## 📌 현재 상황 판단
**{judgment_status}** (인정 가능성: {probability_category})

{judgment_rationale}

## 🛠️ 보완 방법
{missing_evidence_list}

## 📋 다음 단계
{next_steps_list}

---
⚠️ 본 답변은 참고용이며, 최종 판단은 상담사/법원이 합니다.
```

**확률 표현 개선**:
```
70% 이상 → "인정 가능성이 높습니다"
40~70% → "케이스별로 상이하며, 추가 증거에 따라 결과가 달라질 수 있습니다"
40% 이하 → "불인정 가능성이 높습니다. 다음 자료를 보완하면 인정받을 가능성이 높아집니다"
```

**입력 파라미터**:
```json
{
  "user_question": "원래 사용자 질문 (최대 500자)",
  "search_summary": "단계별 검색 결과 요약 (최대 2,000자)",
  "comparison_result": "compare_approval_factors Tool 결과 (최대 1,500자)",
  "evidence_suggestions": "suggest_evidence Tool 결과 (최대 2,000자, 불인정 가능성 높은 경우에만 포함)",
  "focus": "approval_factors | rejection_factors | comparison | legal_basis | remediation"
}
```

**입력 크기 제한**:
- 총 입력 텍스트: **최대 6,000자** (약 2,000~3,000 토큰)
- 각 필드 초과 시 truncate 적용:
  - `user_question`: 500자 초과 시 뒷부분 자름
  - `search_summary`: 검색 결과 5건 요약 + 통계만 포함, 전문 생략
  - `comparison_result`: 통계 + `key_differences`만 포함, 세부 사례 생략
  - `evidence_suggestions`: `missing_evidence` 목록 + `next_steps`만 포함, `recommended_cases` 전문 생략

**출력**: 마크다운 형식의 상담 답변 (템플릿 기반)

**구현 방식**:
- `app/mcp/prompts/explain_determination_prompt.rb` 생성
- **서버 역할**: 템플릿에 Tool 결과 데이터를 매핑하여 구조화된 마크다운 생성
  - `judgment_status`와 `probability_category`는 `approval_rate`에 따라 룰 기반 결정
  - `{next_steps_list}` 매핑: `suggest_evidence`의 `next_steps` 배열(`{action, deadline}` 객체)을 마크다운 리스트로 변환. 예:
    ```ruby
    next_steps_markdown = evidence_suggestions["next_steps"].map do |step|
      "- #{step['action']} (기한: #{step['deadline']})"
    end.join("\n")
    ```
- **클라이언트 역할**: MCP Prompt로 템플릿을 전달받아, `{llm_key_differences_summary}`와 `{judgment_rationale}` 부분을 **클라이언트의 LLM**으로 채움
  - 서버는 `{llm_key_differences_summary}`와 `{judgment_rationale}`를 **빈칸 또는 통계 데이터 요약**으로 미리 채워 제공
  - 클라이언트의 LLM은 이를 자연스러운 문장으로 다듬어 최종 답변 생성

---

### 6. MCP Prompt: `extract_search_keywords`

**목적**: 사용자의 자연어 질문에서 데이터베이스 검색에 적합한 키워드 추출

**입력**: 사용자 원문 질문

> **참고**: MCP Prompt의 출력은 클라이언트의 LLM이 Prompt를 처리하여 생성하는 결과입니다. Tool과 달리 `error`/`data` envelope를 사용하지 않으며, 오류 처리(예: 의도 분석 실패)도 클라이언트 측에서 수행합니다.

**출력**:
```json
{
  "extracted_keywords": "손목 사무실 컴퓨터 근골격계",
  "disease_category_guess": "musculoskeletal",
  "body_part_guess": "hand",
  "suggested_questions": ["진단받은 병명이 있으신가요?", "업무 시작 후 언제부터 증상이 나타났나요?"],
  "required_slots": ["symptom", "work_type"],
  "missing_slots": ["diagnosis"],
  "next_action": "ask_user"
}
```

**구현 방식**:
- `app/mcp/prompts/extract_search_keywords_prompt.rb` 생성
- LLM을 활용한 의도 분류 및 키워드 추출
- **할루시네이션 방지**: Prompt에 DB 허용 값 목록을 동적으로 주입하여 LLM이 없는 카테고리/부위를 생성하지 않도록 제한
  ```ruby
  # Prompt 생성 시 런타임에서 DB enum 값을 조회
  allowed_categories = DiseaseCase.disease_categories.keys  # => ["musculoskeletal", "other_disease", ...]
  allowed_body_parts = DiseaseCase.body_parts.keys          # => ["chest_back", "ear", ...]
  ```
  Prompt 내용 예시:
  ```
  허용 disease_category: {allowed_categories}
  허용 body_part: {allowed_body_parts}
  위 목록에 없는 값은 null로 반환할 것.
  ```
- **슬롯 관리 개선**: `required_slots`, `missing_slots`, `next_action` 필드를 추가하여 클라이언트가 슬롯 누락 시 명확히 대응할 수 있게 함

---

### 7. MCP Resource Template: `disease_case_detail`

**목적**: 특정 판정서의 상세 내용 제공

**URI 템플릿**: `disease-case://{case_no}`

**내용**:
- 신청인 주장 전문
- 인정사실
- 위원회 판단 및 결론
- 관련 법 규정

**구현 방식**:
- `app/mcp/resource_templates/disease_case_detail_resource.rb` 생성
- **개인정보(PII) 마스킹**: DB에 저장된 판정서 원문은 이미 개인정보 마스킹 처리되어 있음 (신청인 실명, 주민번호, 병원명 등). 단, 데이터 유입 경로가 여러 개(크롤링, 수동 입력, 배치 임포트 등)일 경우 예외 데이터가 포함될 수 있으므로, **응답 직전 검증/보호 장치**를 둡니다:
  - `DiseaseCase#as_safe_json` 메서드에서 정규식으로 주민등록번호 패턴(######-#######), 휴대폰 번호, 이메일 주소 등 잔여 PII 패턴을 탐지 및 마스킹(`***`)
  - 탐지 시 `Rails.logger.warn`로 로그 기록 → 데이터 품질 모니터링
  - 마스킹 규칙은 `config/initializers/pii_masking.rb`에 중앙 집중 정의

---

## 데이터 흐름 (개선)

> **서버**: MCP Tool 실행만 수행 (stateless)
> **클라이언트**: 슬롯 관리, LLM 호출, 답변 생성 수행

```
[클라이언트 내부]
사용자 질문
    │
    ▼
슬롯 상태 확인 → 빈 슬롯 있으면 추가 질문 생성 (클라이언트의 LLM)
    │
    ▼
[extract_search_keywords MCP Prompt] ──► 키워드 + 추천 질문
    │
    ▼
슬롯 업데이트 (symptom, work_type, body_part_guess, disease_category_guess)
    │
    ▼
[서버: search_disease_cases Tool] search_in: [application_content, applicant_claim]
    │
    ◄── 1차 사례 검색 결과 (JSON)
    │
    ▼
클라이언트: "유사 사례 {total_count}건을 찾았습니다. (인정 {approved}건, 불인정 {rejected}건) 추가 질문: ..."
    │
    ▼
사용자 추가 정보 제공 → 슬롯 업데이트
    │
    ▼
[서버: search_disease_cases Tool] search_in: +[medical_records, recognized_facts]
    │
    ◄── 2차 보충 검색 결과 (JSON)
    │
    ▼
[서버: compare_approval_factors Tool]
    │
    ◄── 통계 기반 인정/불인정 요인 비교 (JSON)
    │
    ▼
(불인정 가능성 높은 경우)
    │
    ▼
[서버: suggest_evidence Tool]
    │
    ◄── 룰 기반 증거 제안 + 다음 단계 (JSON)
    │
    ▼
[서버: explain_determination MCP Prompt]
    │
    ◄── 템플릿 기반 구조화 마크다운
    │
    ▼
클라이언트의 LLM: 템플릿 빈칸 채우기 → 최종 답변 생성
    │
    ▼
사용자: 📊 유사 사례 결과 → 📌 현재 상황 판단 → 🛠️ 보완 방법
```

---

## UX 개선: 결론 먼저 구조

클라이언트가 생성하는 답변은 **결론 → 근거 → 이유 → 해결** 순서로 구성합니다:

```
📌 현재 상황 판단 (결론)
   └─ 인정 가능성: 40% 이하 → "불인정 가능성이 높습니다"

📊 유사 사례 결과 (근거)
   └─ 총 42건: 인정 28건(66.7%), 불인정 10건(23.8%)

🔍 주요 차이점 (이유)
   └─ 인정 사례: 근전도 양성 85%
   └─ 불인정 사례: 객관적 검사 부재 60%

🛠️ 보완 방법 (해결)
   └─ ① 근전도 검사 ② 동료 증언 ③ 업무 일지
```

**반례 안내**: 동일 조건에서도 불인정 가능성을 명시
> "비슷한 조건에서도 23.8%는 불인정되었습니다. 주요 차이는 객관적 검사 유무입니다."

---

## 구현 우선순위 (개선)

| 순위 | 컴포넌트 | 설명 | 서버 복잡도 | 클라이언트 LLM 의존도 |
|---|---|---|---|---|
| 1 | `suggest_evidence` 룰 데이터 설계 | **질병별 필수 증거 정의** — 시스템의 핵심 차별화 요소 | 중간 (YAML 설계 + 검증) | 낮음 |
| 2 | `compare_approval_factors` 정규식 안정화 | **상태 분류 기반 패턴 추출** — 통계 신뢰도 확보 | 중간 (정규식 + 컨텍스트 추출) | 중간 |
| 3 | `extract_search_keywords` Prompt | 검색 전 전처리 단계 — 먼저 안정화 필요 | 낮음 (Prompt 템플릿) | 높음 (클라이언트 LLM이 키워드 추출) |
| 4 | `search_disease_cases` Tool | 기존 Searchable concern 재사용 | 낮음 (DB 직접 조회) | 없음 |
| 5 | `explain_determination` Prompt | **템플릿 기반 구조화** + 문장 다듬기 | 낮음 (템플릿 매핑) | 중간 (클라이언트가 템플릿 빈칸 채우기) |
| 6 | `get_procedure_guide` Tool | 공식 신청 절차 안내 | 낮음 (YAML 직접) | 없음 |
| 7 | `disease_case_detail` Resource | 상세 판정서 조회 (MVP 필수 아님, Phase 2) | 낮음 | 없음 |

---

## 에러 처리 및 엣지 케이스

### 모든 Tool 공통 응답 규약
각 Tool의 출력에 `error` 필드를 포함하여 실패 여부를 명시:
```json
{
  "error": null,
  "data": { ... }
}
```
또는
```json
{
  "error": "검색어가 너무 짧습니다. 2글자 이상 입력해주세요.",
  "data": null
}
```

### 주요 엣지 케이스 처리

| 상황 | 처리 방식 | 클라이언트 응답 예시 |
|---|---|---|
| **검색 결과 0건** | `search_disease_cases`에서 `used_fallback: true`이고 `total_count: 0`인 경우 | "정확히 일치하는 사례는 없었습니다. 비슷한 키워드로 다시 검색할까요?" |
| **FTS5 검색 실패 + fallback도 0건** | `used_fallback: true`, `total_count: 0` | "해당 증상과 관련된 판정 사례를 찾지 못했습니다. 질병명을 정확히 입력하거나, 산재 지정병원에서 먼저 진단을 받는 것을 권장합니다." |
| **날짜 형식 오류** (`decided_on_from`/`decided_on_to`) | Tool 날짜 파싱 실패 시 `error: "날짜 형식이 올바르지 않습니다. YYYY-MM-DD 형식으로 입력해주세요."` | (시스템 날짜 검증 후 사용자에게 재입력 요청) |
| **MCP Tool 호출 실패** (네트워크/서버 오류) | `error: "검색 서비스에 일시적인 문제가 발생했습니다. 잠시 후 다시 시도해주세요."` | "죄송합니다, 검색 중 문제가 발생했습니다. 다시 한 번 질문해주시겠어요?" |
| **LLM Prompt 실패** (extract_search_keywords) | `error: "질문을 이해하지 못했습니다. 증상과 업무 환경을 구체적으로 알려주세요."` | "어떤 질병/증상인지, 어떤 업무를 하시는지 조금 더 자세히 말씀해주시면 검색해드리겠습니다." |
| **슬롯 정보 부족** | `extract_search_keywords`에서 필수 슬롯(symptom, work_type)이 null인 경우 | "판단에 필요한 정보가 부족합니다. 다음을 알려주시면 더 정확한 분석이 가능합니다: ① 증상 부위 ② 업무 내용 ③ 하루 작업 시간" |

---

## 추가 검토: 통계 페이지 (Statistics Dashboard)

### 필요성
- **설득력 강화**: "66.7%의 손목터널증후군 사례가 인정되었습니다"와 같은 통계는 사용자에게 객관적 신뢰감을 줌
- **불인정 사례 분석**: 불인정된 사유를 카테고리별로 시각화하여 사용자가 자신의 상황과 비교 가능
- **트렌드 파악**: 연도별 인정률 변화, 질병 분류별 인정률 비교

### 구현 내용
```
통계 페이지 (/statistics 또는 /dashboard)
├── 전체 인정률 요약 (승인/불인정/일부인정/정정인정)
├── 질병 분류별 인정률 (musculoskeletal, hearing_loss 등)
├── 신체부위별 인정률
├── 연도별 인정률 추이
├── 불인정 사유 TOP 5 (committee_decision 키워드 분석)
└── 인정에 필요한 주요 증거 자료 (recognized_facts 분석)
```

### 기술 스택 제안
- **백엔드**: 기존 `DiseaseCase` 모델에 통계 scope 추가 (`group(:result).count`, `group(:disease_category).count` 등)
- **프론트엔드**: 별도 JS 차트 라이브러리 없이 CSS/HTML로 구현 (현재 프로젝트에 JS 번들러/빌드 도구 없음)
- **MCP 연동**: `get_statistics` Tool로 통계 데이터 제공, 클라이언트 답변에 인용

### 대안
- 통계 페이지를 별도 웹 페이지로 구현하지 않고, 클라이언트 답변 내에 마크다운 표/리스트로만 통계 제시
- 향후 필요 시 추가 개발

---

## 기존 인프라 활용

- **검색 엔진**: `DiseaseCases::Searchable` (FTS5) — `fulltext()`, `substring_fallback()`
- **필터**: `result`, `disease_category`, `body_part`, `year`, `decided_on`
- **통계**: ActiveRecord `group`, `count`, `average` (별도 차트 라이브러리 불필요)
- **MCP 서버**: `mcp/config.ru` (Falcon) — 이미 설정됨
- **배포**: Kamal 2.x + kamal-proxy (`/mcp` 경로) — 이미 설정됨

---

## 파일 생성 계획

```
app/mcp/tools/
├── application_mcp_tool.rb              # 기존
├── search_disease_cases_tool.rb         # 신규
├── compare_approval_factors_tool.rb     # 신규
├── suggest_evidence_tool.rb             # 신규
└── get_procedure_guide_tool.rb          # 신규

app/mcp/prompts/
├── application_mcp_prompt.rb            # 기존
├── search_disease_case_prompt.rb        # 기존 (리팩토링)
├── extract_search_keywords_prompt.rb    # 신규
└── explain_determination_prompt.rb      # 신규

app/mcp/resource_templates/
├── application_mcp_res_template.rb      # 기존
└── disease_case_detail_resource.rb      # 신규

app/controllers/                          # 통계 페이지 (선택, Phase 2)
└── statistics_controller.rb             # 신규

app/views/statistics/
└── index.html.erb                       # 신규

config/
├── locales/
│   ├── ko.yml                           # 기존 (검색 UI 로케일)
│   ├── en.yml                           # 기존 (검색 UI 로케일)
│   └── procedure_guides.yml             # 신규 (신청 절차 안내 데이터)
└── evidence_rules.yml                   # 신규 (질병별 필수/권장 증거 데이터)
```

---

## 참고 자료: 공식 신청 절차 (근로복지공단 / 산업재해보상보험법)

### 신청 절차
1. **산재 지정병원 방문** → 원무과에서 최초요양급여신청 대행 요청
   - 산재보험 의료기관은 근로자 동의 하에 신청 대행 가능 (산재보험법 제41조 제2항)
   - 사업주 날인은 **2018년 폐지**됨 (신청서에 거부사유 기재 시 날인 없이 제출 가능)
2. **서류 작성**: 최초요양신청서 — 재해 경위를 **6하 원칙**에 따라 상세히 기재
3. **근로복지공단 제출**: 관할 지역본부 또는 지사
4. **업무상질병판정위원회 심의** (질병의 경우): 접수 후 20일 이내 심의 (1차 10일 연장 가능)
5. **처리 결과 통보**: 접수 후 7일 이내 지급 여부 결정 → 신청인 및 사업주 통보

### 필요 서류
| 서류 | 작성 주체 | 비고 |
|---|---|---|
| 요양급여신청서 | 신청인 | 사업주 날인 불필요 |
| 요양급여신청소견서 | 의료기관 (주치의) | 필수 |
| 초진소견서 | 의료기관 | |
| 재해발생경위 서류 | 신청인 | 6하 원칙 상세 기재 |
| 의무기록사본 및 영상자료 | 의료기관 | X-ray, MRI, CT 등 |
| 업무 관련 입증자료 | 신청인 | 근무이력, 근로시간, 업무 환경 등 |
| 10년 치 요양급여내역 | 국민건강보험공단 | |
| 건강검진내역 | 사업장/병원 | |

### 불인정 시 대응 절차
1. **이의신청**: 불승인 처분에 불복 시
2. **재심사 요청**: 새로운 증거 자료 확보 후 재신청
3. **행정소송**: 최종 불복 수단

> **판례 참고**: 사전 질환력이 있더라도 업무가 질병을 악화시킨 경우 업무상 재해로 인정될 수 있음 (대법원 판례)

### 수급 가능한 보험급여
- **요양급여**: 치료비, 입원비 등
- **휴업급여**: 평균임금의 70% (3일 초과 시 지급)
- **장해급여**: 치유 후 장해가 남은 경우 (연금 또는 일시금)
- **간병급여**: 상시/수시 간병 필요 시
- **상병보상연금**: 요양 2년 후 중증 1-3급 해당 시

---

## 고려사항

1. **검색 성능**: FTS5 인덱스 활용, `limit` 파라미터로 결과 제한
2. **핵심 가치**: **불인정 사례를 분석하여 인정을 위한 구체적 보완 방안 제시**가 이 시스템의 가장 중요한 차별점
3. **개인정보**: 판정서 데이터는 공개 정보이나, 상세 내용 제공 시 주의
4. **면책 조항**: "본 답변은 참고용이며, 최종 판단은 상담사/법원이 합니다" 문구 필요
5. **다국어**: `ko.yml`/`en.yml` 로케일 활용, 현재는 한국어 전용
6. **통계 페이지**: Phase 2로 분리, MCP 서버 MVP 완료 후 시각화 페이지 추가 검토
7. **법률 참조**: `related_laws` 컬럼 활용 — 산업재해보상보험법, 시행령, 판례 인용
8. **클라이언트 LLM 부하 최소화**: 서버가 통계/룰 기반으로 80%의 구조화된 데이터를 제공하므로, 클라이언트의 LLM은 20% 설명 보조에만 사용하면 됨
9. **일관성**: 템플릿 기반 응답으로 LLM 응답의 변동성(일관성 저하) 방지
10. **정규식 한계**: 정규식 기반 패턴 분석은 문장 다양성과 부정 표현에 한계가 있음. 향후 형태소 분석(KoNLPy, Mecab) 도입 검토 — 현재 단계에서는 과함
11. **클라이언트 의존성**: 클라이언트마다 동작 차이가 발생할 수 있음. 슬롯 관리 실패 시 `required_slots`/`missing_slots`/`next_action` 필드로 명확한 대응 가이드 제공

---

## 테스트 전략

### 1. 단위 테스트 (Unit Tests)

각 MCP Tool의 핵심 로직을 격리하여 테스트:

| 대상 | 테스트 내용 | 위치 |
|---|---|---|
| `search_disease_cases_tool.rb` | - FTS5 검색 결과 구조 분해 (`scope, fallback`)<br>- 통계 집계 (`group(:result).count`)<br>- `error`/`data` envelope 형식 검증<br>- `confidence_score` 계산 정확도 | `test/mcp/tools/search_disease_cases_tool_test.rb` |
| `compare_approval_factors_tool.rb` | - 인정/불인정 사례 필터링<br>- **상태 분류** (`positive`/`negative`/`not_performed`/`unknown`)<br>- 컨텍스트 추출 (`window: 30`)<br>- 부정어 스코프 처리<br>- 승인률 계산 정확도 | `test/mcp/tools/compare_approval_factors_tool_test.rb` |
| `suggest_evidence_tool.rb` | - `evidence_rules.yml` 로딩 및 파싱<br>- `current_evidence` 대조 필터링<br>- 누락 증거 목록 정확성<br>- `recommended_cases` 생성 로직 | `test/mcp/tools/suggest_evidence_tool_test.rb` |
| `extract_search_keywords_prompt.rb` | - 허용 enum 값 주입 검증<br>- 할루시네이션 방지 (없는 카테고리 → null)<br>- 슬롯 필드(`required_slots`, `missing_slots`) 반환 확인 | `test/mcp/prompts/extract_search_keywords_prompt_test.rb` |

**핵심 테스트 케이스**:
- `DiseaseCase.search` 반환값이 `[scope, fallback]` 튜플인지 확인
- `fallback: true`일 때 `used_fallback: true`가 응답에 포함되는지 확인
- `total_count: 0`일 때 `error: null`, `data.cases: []` 반환 확인
- **부정어 처리**: "근전도 검사 이상 없음" → `:negative`, "근전도 검사 시행 안함" → `:not_performed`
- **동의어 그룹**: "EMG 양성"과 "근전도 이상 소견"이 동일 그룹으로 집계되는지 확인

### 2. 통합 테스트 (Integration Tests)

Tool 체인 전체 흐름 검증:

```
extract_search_keywords → search_disease_cases → compare_approval_factors → suggest_evidence → explain_determination
```

| 시나리오 | 입력 | 검증 포인트 |
|---|---|---|
| 정상 흐름 (인정 가능성 높음) | "손목 아픔, 사무실, 8시간" | - 1차 검색 결과 ≥ 1건<br>- `approval_rate` ≥ 70%<br>- `suggest_evidence`가 필수 증거만 반환 (불인정 시에만 상세) |
| 정상 흐름 (불인정 가능성 높음) | "가끔 손목 불편, 2시간" | - `approval_rate` ≤ 40%<br>- `suggest_evidence`가 보완 방법 포함<br>- `next_steps` 배열 길이 ≥ 1 |
| 슬롯 부족 | "아파요" | - `extract_search_keywords`가 필수 슬롯(symptom, work_type) null 반환<br>- `next_action: "ask_user"` 확인<br>- 챗봇이 추가 질문 유도 |
| 검색 결과 0건 | "매우 희귀한 질병명" | - `total_count: 0`<br>- `used_fallback: true/false` 명시<br>- 적절한 안내 메시지 |
| **부정어 처리** | "근전도 검사 정상, MRI만 이상" | - `compare_approval_factors`의 `emg` 상태가 `:negative`로 분류<br>- `mri` 상태가 `:positive`로 분류 |

**위치**: `test/integration/mcp_chatbot_flow_test.rb`

### 3. 성능 테스트 (Performance Tests)

| 항목 | 목표 | 측정 방법 |
|---|---|---|
| FTS5 검색 응답 시간 | ≤ 200ms (p95) | `Benchmark.measure`로 100회 반복 측정 |
| substring fallback 검색 | ≤ 500ms (p95) | FTS5 실패 시 fallback 경로 별도 측정 |
| 단일 MCP Tool 응답 | ≤ 300ms (p95) | 개별 Tool(`search_disease_cases`, `compare_approval_factors`, `suggest_evidence`)별 측정 |
| MCP Tool 3개 체인 (서버 측) | ≤ 500ms (p95) | `search_disease_cases` → `compare_approval_factors` → `suggest_evidence` 연속 호출 측정 |
| DB 통계 집계 | ≤ 100ms | `group(:result).count` 쿼리 실행 계획 확인 |
| **정규식 상태 분류** | ≤ 50ms/건 (p95) | `extract_status` 함수 100회 반복 측정 |

**부하 테스트**:
- 동시 사용자 10명 × 5분 지속 요청
- 메모리 사용량 모니터링 (Falcon 프로세스당)
- SQLite FTS5 인덱스 크기 추적

---

## Open Questions / 결정 사항

| # | 질문 | 현재 상태 | 결정 필요 시점 |
|---|---|---|---|
| 1 | **LLM Provider 선택** | **사용자/클라이언트가 결정** — 서버는 관여하지 않음 | 해당 없음 |
|   | - 사용자가 자신의 AI 클라이언트(Claude Desktop, Cursor, 기타)에서 선택한 LLM을 사용 | | |
|   | - 서버는 MCP Protocol로 Tool/Prompt만 제공하며, LLM API 키나 모델 선택에 관여하지 않음 | | |
|   | **참고**: 판정서 원문은 이미 개인정보 마스킹 처리되어 있으므로, 클라이언트가 외부 LLM API로 전송 시 PII 유출 위험이 낮음. 단, 사용자가 자연어 질문에 PII를 직접 입력할 가능성은 클라이언트/사용자가 관리 | | |
| 2 | **슬롯 기반 대화 상태 저장소** | **불필요 — 서버는 stateless** | 해당 없음 |
|   | - MCP 서버는 요청/응답만 처리하고 세션을 저장하지 않음 | | |
|   | - 대화 상태(슬롯)는 **클라이언트**가 관리 (Claude Desktop의 memory, Cursor의 chat context 등) | | |
|   | - 서버 재시작/스케일아웃에 영향 없음 | | |
| 3 | **통계 페이지 우선순위** | Phase 2로 분리 | MCP 서버 MVP 완료 후 |
|   | - Phase 1: 클라이언트 답변 내 마크다운 표로만 통계 제시 | | |
|   | - Phase 2: 별도 `/statistics` 웹 페이지 구현 | | |
|   | *선택 기준*: 개발 리소스, 사용자 피드백 | | |
| 4 | **LLM Fallback 전략** | **클라이언트가 처리** — 서버는 관여하지 않음 | 해당 없음 |
|   | - 서버는 `error`/`data` envelope로 정상 응답만 반환 | | |
|   | - LLM API 실패/지연 등은 클라이언트가 자체적으로 처리 (재시도, 템플릿 기반 fallback, 사용자 안내 등) | | |
|   | - 서버는 `llm_explanation`/`llm_tailored_advice`를 `null`로 반환하며, **클라이언트 LLM이 채워야 할 자리**입니다 | | |
| 5 | **증거 룰 데이터(`evidence_rules.yml`) 관리** | 초안 작성됨 | 운영 전 |
|   | - 누가 업데이트 담당? (개발자 / 의료 상담사 / 법률 자문) | | |
|   | - 법 개정 시 반영 프로세스? | | |
|   | - 룰 검증 방법? (단위 테스트 / 전문가 리뷰) | | |
| 6 | **정규식 → 형태소 분석 전환** | 현재: 정규식 기반 상태 분류 | 향후 검토 |
|   | - KoNLPy/Mecab 도입 시 정확도 ↑ but 비용 ↑ | | |
|   | - 현재 단계에서는 정규식 + 컨텍스트 추출로 충분하다는 판단 | | |
|   | *전환 기준*: 정규식 오분류율 > 20% 또는 룰 데이터 50개 이상 축적 시 | | |

---

## 리뷰 반영 요약 (v1 → v2)

| # | 반영 사항 | 출처 |
|---|---|---|
| 1 | `confidence_score` + `confidence_reason` 추가 | mcp-plan-1-review.md #4.1 |
| 2 | `match_reason` 태그 추가 | mcp-plan-1-review.md #4.2 |
| 3 | 승인률 분리: `strict_approval_rate` / `substantive_approval_rate` | mcp-plan-1-review.md #3.3 |
| 4 | **3단계 상태 분류** (positive/negative/not_performed/unknown) + 컨텍스트 추출 | compare_approval_factors_tool.md |
| 5 | 부정어 스코프 처리 + 문장 단위 분리 | compare_approval_factors_tool.md #5 |
| 6 | 확장 가능한 `EXTRACTION_RULES` 구조 | compare_approval_factors_tool.md #6 |
| 7 | `evidence_rules.yml` 상세 구조화 (`key`, `notes`, `risk_factors`, `strong_approval_signals`) | evidence_rules.yml.md |
| 8 | 슬롯 관리 개선 (`required_slots`, `missing_slots`, `next_action`) | mcp-plan-1-review.md #3.1 |
| 9 | UX "결론 먼저" 구조 추가 | mcp-plan-1-review.md #5 |
| 10 | 반례 안내 가이드 추가 | mcp-plan-1-review.md #4.3 |
| 11 | `recommended_cases` 생성 방법 상세화 | 7차 리뷰 #2 |
| 12 | 오타 수정: "클라이언트" → "클라이언트" | 7차 리뷰 #1 |
