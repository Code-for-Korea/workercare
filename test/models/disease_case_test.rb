# frozen_string_literal: true

require "test_helper"

class DiseaseCaseTest < ActiveSupport::TestCase
  test "destroying a case with mapped KSCO codes does not raise a foreign key error" do
    disease_case = DiseaseCase.create!(case_no: "TEST-DESTROY-KSCO", year: 2024)
    ksco_code = KscoCode.create!(code: "TEST-DESTROY-9999", name: "테스트 직업")
    DiseaseCaseKscoCode.create!(disease_case: disease_case, ksco_code: ksco_code, similarity: 0.5)

    assert_nothing_raised { disease_case.destroy! }
    assert_empty DiseaseCaseKscoCode.where(disease_case_id: disease_case.id)
  end
end
