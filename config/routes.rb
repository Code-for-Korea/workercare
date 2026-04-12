Rails.application.routes.draw do
  root "disease_cases#index"
  get "/about", to: "pages#about", as: :about

  resources :disease_cases, param: :case_no, only: [ :index, :show ]

  get "up" => "rails/health#show", :as => :rails_health_check
end
