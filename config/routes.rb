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
    
    resources :orders do
      resources :order_vehicles, only: [:index, :new, :create, :edit, :update] do
        patch :unset_current, on: :member
        get :suggest, on: :collection
      end

      collection do
        get :all_orders
        get :pending_orders
        get :planned_orders
        get :in_progress_orders 
        get :completed_orders
      end

    end
  
    resources :drivers do
      member do
        get :driver_history 
      end
    end

    resources :vehicles do
      resources :vehicle_drivers, only: [:index, :new, :create, :edit, :update] do
        patch :unset_current, on: :member
      end
    end
    resources :availabilities
  
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
