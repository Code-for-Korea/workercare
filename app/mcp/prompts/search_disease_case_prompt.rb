class SearchDiseaseCasePrompt < ApplicationMCPPrompt
  prompt_name "search_disease_case"
  description "Search for cases of occupational disease determination filed for industrial accident compensation insurance."

  # Configure arguments (example structure — override as needed)
  argument :input, description: "Main input", required: true

  # Optional: add more arguments if needed
  # argument :context, description: "Context for the input", default: ""

  # Optional: validations can be added as needed
  # validates :input, presence: true
  # validates :context, length: { maximum: 500 }

  def perform
    render(text: "hello world")
  end
end
