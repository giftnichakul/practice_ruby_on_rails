Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: 'users/sessions' }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "books#index"

  resources :books do
    resources :reviews
  end

  # resources :books, only: [:index]
  # resources :reviews, only: [:index]
end
