Rails.application.routes.draw do
  root "disease_cases#index"
  get "/search", to: "disease_cases#search", as: :search
  get "/about", to: "pages#about", as: :about

  resources :disease_cases, param: :case_no, only: [ :show ]

  post "/webhooks/kakao", to: "webhooks/kakao#create"
  post "/webhooks/kakao/jobs", to: "webhooks/kakao_jobs#create"

  get "up" => "rails/health#show", :as => :rails_health_check
end
