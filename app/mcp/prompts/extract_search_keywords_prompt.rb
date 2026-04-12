# frozen_string_literal: true

class ExtractSearchKeywordsPrompt < ApplicationMCPPrompt
  prompt_name "extract_search_keywords"
  description "Extract search keywords, guess disease category and body part, and identify missing required slots from a user's natural language question."

  argument :user_question,
           description: "The user's original natural language question (max 500 characters)",
           required: true

  def perform
    allowed_categories = DiseaseCase.disease_categories.keys.join(", ")
    allowed_body_parts = DiseaseCase.body_parts.keys.join(", ")

    render text: <<~PROMPT
      사용자의 질문에서 데이터베이스 검색에 적합한 키워드를 추출하고, 필요한 정보 슬롯을 식별하세요.

      허용 disease_category: #{allowed_categories}
      허용 body_part: #{allowed_body_parts}
      위 목록에 없는 값은 null로 반환할 것.

      필수 슬롯: symptom, work_type
      사용자 질문: #{user_question.to_s.truncate(500)}

      다음 JSON 형식으로 응답하세요:
      {
        "extracted_keywords": "검색 키워드 문자열",
        "disease_category_guess": "추정 질병 카테고리 (없으면 null)",
        "body_part_guess": "추정 신철 부위 (없으면 null)",
        "suggested_questions": ["사용자에게 물어볼 추가 질문1", "질문2"],
        "required_slots": ["symptom", "work_type"],
        "missing_slots": ["diagnosis"],
        "next_action": "ask_user"
      }
    PROMPT
  end
end
