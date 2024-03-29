Rails.application.routes.draw do
  resources :entries, only: [:index, :new, :create, :edit,  :update, :destroy]
  resources :categories, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :accounts
  root to:'accounts#index'
  get "/reporting", to: 'entries#reporting'
  mount PgHero::Engine, at: "pghero"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
