Rails.application.routes.draw do
  devise_for :users
  root "landing#show"
  resources :leads, only: :create
end
