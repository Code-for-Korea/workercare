Rails.application.routes.draw do
  root "disease_cases#index"
  # root는 확장자를 받지 못하므로 마크다운용 /index.md 를 따로 둔다.
  get "/index", to: "disease_cases#index", as: :index
  get "/search", to: "disease_cases#search", as: :search
  post "/display-settings", to: "display_settings#update", as: :display_settings
  get "/about", to: "pages#about", as: :about
  get "/apply-guide", to: "pages#apply_guide", as: :apply_guide

  # 산재알아보기(단계형 자가진단). 정적 경로를 먼저 두고 /:step은 Flow의 질문 단계 이름으로만 받는다.
  # resource :self_care_form(단수 리소스)은 복수 SelfCareFormsController로 연결되므로 controller를 명시한다.
  scope "self-care-form", controller: :self_care_form, as: :self_care_form do
    get  "",       action: :start,  as: :start
    post "",       action: :agree,  as: :agree
    get  "review", action: :review, as: :review
    get  "result", action: :result, as: :result
    post "result", action: :submit_result, as: :submit_result
    post "reset",  action: :reset,  as: :reset
    step_keys = /#{SelfCareForm::Flow::STEP_KEYS.join("|")}/
    get  ":step",  action: :show,   as: :step, constraints: { step: step_keys }
    post ":step",  action: :update, constraints: { step: step_keys }
  end

  resources :disease_cases, param: :case_no, only: [ :show ]

  post "/webhooks/kakao", to: "webhooks/kakao#create"
  post "/webhooks/kakao/jobs", to: "webhooks/kakao_jobs#create"

  get "up" => "rails/health#show", :as => :rails_health_check
end
