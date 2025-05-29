Rails.application.routes.draw do
  root "subscriptions#index"

  devise_for :admin_users, controllers: {
    registrations: 'admin_users/registrations'
  }
#忘れないためにコメントを書きます。（これで問題なければこのコメントは消します。)ネストした理由は、利用ユーザー一覧画面の詳細ボタンを押した時個別のユーザーのサブスク一覧画面に遷移させるためです。subscriptions_path(line_user)で直接引数を渡せないため。
  resources :line_users do
    resources :subscriptions, only: [:index]
  end

  resources :subscriptions

  post 'line/callback', to: 'line_bots#callback'
end
