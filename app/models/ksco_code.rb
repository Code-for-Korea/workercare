class KscoCode < ApplicationRecord
  self.primary_key = "code"

  has_many :disease_case_ksco_codes, primary_key: "code", foreign_key: "ksco_code_id"
  has_many :disease_cases, through: :disease_case_ksco_codes
end
