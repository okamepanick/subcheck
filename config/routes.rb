Rails.application.routes.draw do
  root "subscriptions#index"

  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }
  resources :subscriptions

  post 'line/callback', to: 'line_bots#callback'
end
