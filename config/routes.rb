Rails.application.routes.draw do
  root "home#landing"

  devise_for :users, controllers: {
    registrations: "users/registrations",
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  authenticated :user do
    get "/dashboard", to: "dashboard#show", as: :dashboard

    resources :projects, param: :id, except: [:destroy] do
      resources :briefs, only: [:new, :create, :show]

      resource :landing, only: [:edit, :update], controller: "landings"

      resource :landing_settings, only: [:edit, :update]
      get "preview", to: "previews#show"
    end
  end

  # Public
  get "/l/:slug", to: "landing#show", as: :landing_show

  # Leads (public post)
  post "/l/:project_slug/leads", to: "leads#create", as: :project_leads
end
