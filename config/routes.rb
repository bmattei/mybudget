Rails.application.routes.draw do
  resources :entries, only: [:index]
  resources :categories do
    resources :entries, only: [:index]
  end
  resources :accounts do
    resources :entries, only: [:index, :new, :update, :destroy, :edit]
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
