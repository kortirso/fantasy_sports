# frozen_string_literal: true

Rails.application.routes.draw do
  localized do
    namespace :users do
      get 'sign_up', to: 'registrations#new'
      post 'sign_up', to: 'registrations#create'

      get 'login', to: 'sessions#new'
      post 'login', to: 'sessions#create'
      get 'logout', to: 'sessions#destroy'
    end

    resource :home, only: %i[show]
    resources :fantasy_teams, only: %i[show create update] do
      resources :transfers, only: %i[index], module: 'fantasy_teams'
      resources :points, only: %i[index], module: 'fantasy_teams'
      resources :players, only: %i[index], module: 'fantasy_teams'
    end
    namespace :fantasy_teams do
      resources :lineups, only: %i[] do
        resource :players, only: %i[show update], module: 'lineups'
      end
    end
    resources :sports, only: %i[] do
      get 'positions', on: :collection, to: 'sports/positions#index'
    end
    resources :teams, only: %i[index] do
      get 'players', on: :collection, to: 'teams/players#index'
    end

    root 'welcome#index'
  end
end
