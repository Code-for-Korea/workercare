class DiseaseCasesController < ApplicationController
  def show
    @case = DiseaseCase.find(params[:id])
  end
end
