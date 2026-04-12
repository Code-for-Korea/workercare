# frozen_string_literal: true

class GetProcedureGuideTool < ApplicationMCPTool
  tool_name "get_procedure_guide"
  title "Get Procedure Guide"
  description "Provide official application procedures, required documents, rejection appeal methods, compensation types, and timeline."
  read_only
  open_world false

  property :topic,
           type: "string",
           description: "Topic to retrieve. Allowed: application, required_documents, rejection_appeal, compensation_types, timeline",
           required: true,
           enum: %w[application required_documents rejection_appeal compensation_types timeline]

  property :disease_name,
           type: "string",
           description: "User's disease name for context-aware guidance",
           required: false

  property :body_part,
           type: "string",
           description: "Affected body part",
           required: false

  property :work_environment,
           type: "string",
           description: "User's work environment",
           required: false

  def perform
    guides = load_guides
    content = guides[topic.to_s]

    unless content
      return render structured: {
        error: "해당 주제의 안내를 찾을 수 없습니다. 올바른 topic 값을 사용해주세요.",
        data: nil
      }
    end

    render structured: {
      error: nil,
      data: contextualize(content)
    }
  rescue => e
    Rails.logger.error("[GetProcedureGuideTool] #{e.class}: #{e.message}")
    render structured: {
      error: "절차 안내를 불러오는 중 오류가 발생했습니다.",
      data: nil
    }
  end

  private

  def load_guides
    yaml = YAML.load_file(Rails.root.join("config/locales/procedure_guides.yml"))
    yaml["ko"] || {}
  rescue Errno::ENOENT
    {}
  end

  def contextualize(content)
    context_parts = []
    context_parts << "질병: #{disease_name}" if disease_name.present?
    context_parts << "부위: #{body_part}" if body_part.present?
    context_parts << "업무환경: #{work_environment}" if work_environment.present?

    if context_parts.any?
      "#{content}\n\n_사용자 상황: #{context_parts.join(", ")}_"
    else
      content
    end
  end
end
