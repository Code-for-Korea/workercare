class DiseaseCasesController < ApplicationController
  def show
    @disease_case = DiseaseCase.find(params[:id])
  end
end
