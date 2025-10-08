Rails.application.routes.draw do
  devise_for :users
  resources :orders, only: [:new, :show, :create] do
    collection do
      get :preview
      post :preview 
    end
  end

  namespace :admin do
    root "dashboard#index"
    resources :users, only: [:index, :edit, :update, :destroy]
    get "settings", to: "dashboard#settings"
    get "reports", to: "dashboard#reports"
  end


  namespace :dispatcher do
    root "dashboard#index"
    resources :orders, only: [:index, :show, :edit, :update, :destroy]
    resources :drivers
    get "calendar", to: "dashboard#calendar"
    get "notifications", to: "dashboard#notifications"
  end
  
  namespace :client do
    root "dashboard#index"
    resources :orders, only: [:index, :show, :edit, :update, :destroy]
    get "calendar", to: "dashboard#calendar"
    get "notifications", to: "dashboard#notifications"
  end

  root "orders#new"
  match "/404", to: "errors#not_found", via: :all
end
