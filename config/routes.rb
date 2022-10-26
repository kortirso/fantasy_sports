# frozen_string_literal: true

Rails.application.routes.draw do
  mount Emailbutler::Engine => '/emailbutler'
  mount PgHero::Engine, at: 'pghero'

  localized do
    namespace :admin do
      get '', to: 'welcome#index'

      resources :leagues, only: %i[index new create]
    end

    namespace :users do
      get 'sign_up', to: 'registrations#new'
      post 'sign_up', to: 'registrations#create'
      get 'confirm', to: 'registrations#confirm', as: :confirm

      get 'complete', to: 'confirmations#complete', as: :complete

      get 'login', to: 'sessions#new'
      post 'login', to: 'sessions#create'
      get 'logout', to: 'sessions#destroy'
    end

    resource :home, only: %i[show]
    resources :fantasy_teams, only: %i[show create update] do
      scope module: :fantasy_teams do
        resource :transfers, only: %i[show update]
        resources :points, only: %i[index]
        resources :players, only: %i[index]
        resources :fantasy_leagues, only: %i[index new create]
      end
    end
    resources :lineups, only: %i[] do
      resource :players, only: %i[show update], module: 'lineups'
    end
    resources :sports, only: %i[] do
      resources :positions, only: %i[index], module: 'sports'
    end
    resources :teams, only: %i[index]
    resources :seasons, only: %i[] do
      resources :players, only: %i[index show], module: 'seasons'
    end
    resources :weeks, only: %i[show] do
      resources :opponents, only: %i[index], module: 'weeks'
    end
    resources :fantasy_leagues, only: %i[show] do
      scope module: :fantasy_leagues do
        resources :joins, only: %i[index]
      end
    end

    root 'welcome#index'
  end
end
