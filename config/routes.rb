Rails.application.routes.draw do
  get "messages/index"
  devise_for :users
  resources :orders, only: [ :new, :show, :create ] do
    collection do
      get :preview
      post :preview
    end
  end

  resources :messages, only: [ :index ] do
    collection do
      post :connect
      post :disconnect
      post "mark_as_read/:conversation_id", action: :mark_as_read, as: :mark_as_read
      post :send_message
      post :ensure_driver_conversation
    end
  end

  namespace :admin do
    root "dashboard#index"
    resources :users, only: [ :index, :edit, :update, :destroy ]
    get "settings", to: "dashboard#settings"
    get "reports", to: "dashboard#reports"
  end


  namespace :dispatcher do
    root "dashboard#index"

    resources :orders do
      post :send_whatsapp, on: :member
      resources :order_vehicles, only: [ :index, :new, :create, :edit, :update ] do
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

      collection do
        get :all_drivers
        get :available_drivers
        get :unavailable_drivers
      end
    end

    resources :vehicles do
      resources :vehicle_drivers, only: [ :index, :new, :create, :edit, :update ] do
        patch :unset_current, on: :member
      end

      collection do
        get :all_vehicles
        get :available_vehicles
        get :unavailable_vehicles
      end
    end
    resources :availabilities


    get "calendar", to: "dashboard#calendar"
    get "notifications", to: "dashboard#notifications"
  end


  namespace :client do
    root "dashboard#index"
    resources :orders, only: [ :index, :show, :edit, :update, :destroy ]
    get "calendar", to: "dashboard#calendar"
    get "notifications", to: "dashboard#notifications"
  end

  namespace :api do
    post "whatsapp_session/qr",     to: "whatsapp_sessions#qr"
    post "whatsapp_session/status", to: "whatsapp_sessions#status"
    post "whatsapp_session/connect", to: "whatsapp_sessions#connect"
    post "whatsapp_session/disconnect", to: "whatsapp_sessions#disconnect"

    resource :whatsapp_session, only: [ :create ]
    resources :whatsapp_messages, only: [ :create ]
  end


  root "orders#new"
  match "/404", to: "errors#not_found", via: :all
end
