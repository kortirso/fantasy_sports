# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :users do
    get 'sign_up', to: 'registrations#new'
    post 'sign_up', to: 'registrations#create'

    get 'login', to: 'sessions#new'
    post 'login', to: 'sessions#create'
    get 'logout', to: 'sessions#destroy'
  end

  resource :home, only: %i[show]
  resources :fantasy_teams, only: %i[show create]

  root 'welcome#index'
end
