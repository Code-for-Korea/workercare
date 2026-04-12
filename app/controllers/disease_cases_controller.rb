class DiseaseCasesController < ApplicationController
  def show
    @disease_case = DiseaseCase.find_by(case_no: params[:case_no])
  end
end
