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

  # Cron用のURLからRakeタスクを実行
  namespace :cron do
    get 'send_daily_reminders', to: 'subscriptions#send_daily_reminders_job'
    get 'update_billing_date', to: 'subscriptions#update_billing_date_job'
  end

  namespace :api do
    resources :subscriptions, only: [:index, :create]
  end
end
