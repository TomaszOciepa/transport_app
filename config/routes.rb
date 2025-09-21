Rails.application.routes.draw do
  resources :orders, only: [:new, :show, :create] do
    collection do
      post :preview 
    end
  end
  root "orders#new"
end
