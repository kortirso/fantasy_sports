# frozen_string_literal: true

require 'que/view'

Rails.application.routes.draw do
  mount Emailbutler::Engine => '/emailbutler'
  mount PgHero::Engine, at: 'pghero'
  mount Que::View::Engine => '/que_view'

  namespace :admin do
    get '', to: 'welcome#index'

    resources :feedbacks, only: %i[index]
    resources :players, except: %i[destroy]
    resources :leagues, only: %i[index new create]
    resources :seasons, only: %i[index new create] do
      scope module: :seasons do
        resources :games, except: %i[show] do
          resources :statistics, only: %i[index create], module: 'games'
        end
        resources :teams_players, only: %i[index new edit create update]
        resources :teams, only: %i[index show]
        resources :injuries, only: %i[index new create edit update destroy]
      end
    end
  end

  namespace :api do
    namespace :frontend do
      resource :feedback, only: %i[create]
      resources :fantasy_teams, only: %i[destroy] do
        scope module: :fantasy_teams do
          resources :fantasy_leagues, only: %i[index create]
        end
      end
      resources :players_seasons, only: %i[] do
        scope module: :players_seasons do
          resources :watches, only: %i[create] do
            delete :destroy, on: :collection
          end
        end
      end
      resources :lineups, only: %i[] do
        resource :players, only: %i[show], module: 'lineups'
      end
    end
  end

  namespace :users do
    get 'sign_up', to: 'registrations#new'
    post 'sign_up', to: 'registrations#create'
    get 'confirm', to: 'registrations#confirm', as: :confirm

    get 'complete', to: 'confirmations#complete', as: :complete

    get 'login', to: 'sessions#new'
    post 'login', to: 'sessions#create'
    get 'logout', to: 'sessions#destroy'

    get 'restore', to: 'restore#new', as: :restore
    post 'restore', to: 'restore#create'

    get 'recovery', to: 'recovery#new', as: :recovery
    post 'recovery', to: 'recovery#create'
  end

  namespace :profile do
    resources :achievements, only: %i[index]
  end

  resource :home, only: %i[show]
  resources :fantasy_teams, only: %i[show create update] do
    scope module: :fantasy_teams do
      resource :transfers, only: %i[show update]
      resources :status, only: %i[index]
      resources :points, only: %i[index]
      resources :players, only: %i[index]
    end
  end
  resources :lineups, only: %i[] do
    resource :players, only: %i[update], module: 'lineups'
  end
  resources :sports, only: %i[] do
    resources :positions, only: %i[index], module: 'sports'
  end
  resources :teams, only: %i[index]
  resources :seasons, only: %i[] do
    resources :players, only: %i[index show], module: 'seasons'
    resources :best_players, only: %i[index], module: 'seasons'
  end
  resources :weeks, only: %i[show] do
    scope module: :weeks do
      resources :opponents, only: %i[index]
      resources :transfers, only: %i[index]
    end
  end
  resources :fantasy_leagues, only: %i[show] do
    resources :joins, only: %i[index], module: 'fantasy_leagues'
  end
  resources :rules, only: %i[index]
  resources :lineups, only: %i[show update]
  resources :games, only: %i[] do
    resources :statistics, only: %i[index], module: 'games'
  end
  resources :achievement_groups, only: %i[index]
  resources :achievements, only: %i[index]
  resources :cups, only: %i[show]

  get 'privacy', to: 'welcome#privacy'

  root 'welcome#index'
end
