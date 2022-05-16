Rails.application.routes.draw do
  resources :entries, only: [:index, :new, :create, :edit,  :update, :destroy]
  resources :categories
  resources :accounts
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
