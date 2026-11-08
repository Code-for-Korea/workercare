Rails.application.routes.draw do
  root "disease_cases#index"
  # root는 확장자를 받지 못하므로 마크다운용 /index.md 를 따로 둔다.
  get "/index", to: "disease_cases#index", as: :index
  get "/search", to: "disease_cases#search", as: :search
  get "/about", to: "pages#about", as: :about
  get "/apply-guide", to: "pages#apply_guide", as: :apply_guide

  resources :disease_cases, param: :case_no, only: [ :show ]

  post "/webhooks/kakao", to: "webhooks/kakao#create"
  post "/webhooks/kakao/jobs", to: "webhooks/kakao_jobs#create"

  get "up" => "rails/health#show", :as => :rails_health_check
end
