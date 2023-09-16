Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  root 'home#index'
  get '/signup', to: 'users#new'
  resources :users, only: [:create, :show]
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'

  resources :projects do
    resources :contributions, only: [:new, :create, :show, :edit, :update]
  end

  mount Split::Dashboard, at: 'split'
end
