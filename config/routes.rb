Rails.application.routes.draw do
  root "landing#show"
  # root "home#landing"
  get "/landing-template", to: "landing#show", as: "landing_template1"

  resources :leads, only: :create

  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  authenticated :user do
    get "/dashboard", to: "dashboard#show", as: :dashboard
    root to: "dashboard#show", as: :authenticated_root
  end
end
