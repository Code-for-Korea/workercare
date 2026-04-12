Rails.application.routes.draw do
  root "searches#index"
  get "/search", to: "searches#search", as: :search
  get "/about", to: "pages#about", as: :about

  resources :disease_cases, only: :show

  get "up" => "rails/health#show", as: :rails_health_check
end
