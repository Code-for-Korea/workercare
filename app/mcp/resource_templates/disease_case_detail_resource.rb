# frozen_string_literal: true

class DiseaseCaseDetailResource < ApplicationMCPResTemplate
  description "Detailed contents of a specific occupational disease determination case."
  uri_template "disease-case://{case_no}"
  mime_type "application/json"

  parameter :case_no,
            description: "Case number (e.g., 2023-001234)",
            required: true

  validates :case_no,
            presence: { message: "case_no is required" }

  def self.list(session: nil)
    DiseaseCase.limit(100).map do |c|
      build_resource(
        uri: "disease-case://#{c.case_no}",
        name: "#{c.case_no} - #{c.disease_name}",
        title: "Case #{c.case_no}",
        description: "#{c.disease_name} (#{c.result_label})"
      )
    end
  end

  def resolve
    disease_case = DiseaseCase.find_by(case_no: case_no)
    return nil unless disease_case

    ActionMCP::Content::Resource.new(
      "disease-case://#{case_no}",
      mime_type,
      text: disease_case.as_safe_json.to_json
    )
  end
end
