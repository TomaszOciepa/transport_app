Rails.application.routes.draw do
  resources :orders, only: [:new, :show, :create] do
    collection do
      get :preview
      post :preview 
    end
  end
  root "orders#new"
  match "/404", to: "errors#not_found", via: :all
end
