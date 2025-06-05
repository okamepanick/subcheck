Rails.application.routes.draw do
  root "line_users#index"

  devise_for :admin_users, controllers: {
    registrations: 'admin_users/registrations'
  }
#利用ユーザー一覧
  resources :line_users, only: [:index]
#サブスクリプション
  resources :subscriptions

  post 'line/callback', to: 'line_bots#callback'
end
