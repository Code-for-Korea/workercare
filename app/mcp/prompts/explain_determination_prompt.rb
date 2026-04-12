# frozen_string_literal: true

class ExplainDeterminationPrompt < ApplicationMCPPrompt
  prompt_name "explain_determination"
  description "Template-based structured explanation for occupational disease determination counseling."

  argument :user_question,
           description: "Original user question (max 500 characters)",
           required: true

  argument :search_summary,
           description: "Step-by-step search result summary (max 2000 characters)",
           required: true

  argument :comparison_result,
           description: "compare_approval_factors tool result (max 1500 characters)",
           required: true

  argument :evidence_suggestions,
           description: "suggest_evidence tool result (max 2000 characters, include only when rejection risk is high)",
           required: false,
           default: ""

  argument :focus,
           description: "Focus area: approval_factors | rejection_factors | comparison | legal_basis | remediation",
           required: false,
           default: "approval_factors"

  def perform
    truncated_question = user_question.to_s.truncate(500)
    truncated_search = search_summary.to_s.truncate(2000)
    truncated_comparison = comparison_result.to_s.truncate(1500)
    truncated_evidence = evidence_suggestions.to_s.truncate(2000)

    render text: <<~PROMPT
      ## 상담 답변 템플릿

      아래 데이터를 바탕으로 사용자에게 이해하기 쉽게 설명하세요. 반드시 "결론 → 근거 → 이유 → 해결" 순서로 구성하세요.

      ### 입력 데이터
      - 사용자 질문: #{truncated_question}
      - 검색 요약: #{truncated_search}
      - 비교 분석: #{truncated_comparison}
      - 증거 제안: #{truncated_evidence}
      - 초점: #{focus}

      ### 출력 형식
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

      ### 확률 표현 가이드
      - 70% 이상 → "인정 가능성이 높습니다"
      - 40~70% → "케이스별로 상이하며, 추가 증거에 따라 결과가 달라질 수 있습니다"
      - 40% 이하 → "불인정 가능성이 높습니다. 다음 자료를 보완하면 인정받을 가능성이 높아집니다"

      ### 반례 안내 (필수)
      동일 조건에서도 불인정 가능성을 명시하세요. 예: "비슷한 조건에서도 {rejection_rate}는 불인정되었습니다. 주요 차이는 {key_difference}입니다."

      총 출력은 6000자 이내로 유지하세요.
    PROMPT
  end
end
