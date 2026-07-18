class DiseaseCaseKscoCode < ApplicationRecord
  belongs_to :disease_case
  belongs_to :ksco_code, primary_key: "code", foreign_key: "ksco_code_id"
end
