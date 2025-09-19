Rails.application.routes.draw do
  root "landing#show"
  resources :leads, only: :create
end
