Rails.application.routes.draw do
  root "subscriptions#index"
  devise_for :users
  resources :subscriptions
end
