Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: 'home#index'

  get 'auth/:provider/callback', to: 'sessions#callback'
  get '/logout', to: 'sessions#destroy'

  namespace :admin do
    namespace :github do
      resource :all_fetch, only: [:create]
      resources :repositories, only: [:new, :create]
    end
  end

  namespace :github do
    resources :users, only: [:show] do
      scope module: :users do
        resources :repositories, only: [:show] do
          scope module: :repositories do
            resource :update_jobs, only: [:create]
          end
        end
      end
    end
  end

  namespace :ruby do
    resources :gems, only: [:show], param: :name
    namespace :gems do
      resources :search, only: [:show]
    end
    resources :versions, only: [:index]
  end
end
