Rails.application.routes.draw do
  # Devise認証
  devise_for :users

  # ルートパスをダッシュボードに設定
  root "dashboard#index"

  # メインの機能
  resources :transactions do
    collection do
      get :stats      # 統計情報取得
    end
  end

  resources :reservations do
    member do
      patch :pay      # 支払い完了
      patch :cancel   # キャンセル
    end
  end

  resources :subscriptions do
    member do
      patch :pause    # 一時停止
      patch :resume   # 再開
    end
  end

  resources :categories

  # 設定
  get "settings", to: "settings#index"
  post "settings/update_budget", to: "settings#update_budget"
  delete "settings/delete_budget/:id", to: "settings#delete_budget", as: "delete_budget"

  # API endpoints（将来的にAjax用）
  namespace :api do
    namespace :v1 do
      resources :categories, only: [ :index ]
      resources :transactions, only: [ :create ]
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by uptime monitors, Docker healthchecks, etc.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
