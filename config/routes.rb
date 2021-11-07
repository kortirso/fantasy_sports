# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :users do
    get 'sign_up', to: 'registrations#new'
    post 'sign_up', to: 'registrations#create'

    get 'login', to: 'sessions#new'
    post 'login', to: 'sessions#create'
    get 'logout', to: 'sessions#destroy'
  end

  root 'welcome#index'
end
