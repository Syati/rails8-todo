Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  devise_for :admins, path: "auth", controllers: {
    omniauth_callbacks: "omniauth_callbacks" # コールバック用
  }, omniauth_providers: [ :developer ]

  get "auth/:provider/callback", to: "sessions#create"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # FAQ
  get "faq", to: "faq#index"

  # Back-office screens rendered by Rails.
  namespace :console do
    resources :admins
    resources :products do
      resources :skus, only: %i[new create edit update destroy]
    end
  end

  # POST /oauth/token issues client credentials tokens, and /oauth/applications registers clients.
  use_doorkeeper do
    skip_controllers :authorizations, :authorized_applications
  end

  # JSON API for the Next.js back office. The contract is api/openapi.yaml, built from api/*.tsp.
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :products, only: %i[index show create update destroy] do
        resources :skus, only: %i[create update destroy], shallow: true
      end
    end

    get "docs", to: "docs#show", defaults: { format: :html }
    get "docs/openapi.yaml", to: "docs#openapi", as: :docs_openapi, defaults: { format: :yaml }
  end

  # Defines the root path route ("/")
  root "dashboard#index"

  # Silently handle Chrome DevTools discovery requests
  get ".well-known/appspecific/*path", to: proc { [ 204, {}, [] ] }
end
