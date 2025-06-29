Rails.application.routes.draw do
  root "line_users#index"

  devise_for :admin_users, controllers: {
    registrations: 'admin_users/registrations'
  }
#利用ユーザー一覧
  resources :line_users, only: [:index]
#サブスクリプション
  resources :subscriptions
  
  # LIFF routes for LINE integration
  get 'liff/subscriptions/new', to: 'subscriptions#liff_new', as: 'liff_new_subscription'
  get 'liff/subscriptions/edit', to: 'subscriptions#liff_edit', as: 'liff_edit_subscription'

  post 'line/callback', to: 'line_bots#callback'
end
