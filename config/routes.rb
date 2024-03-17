# frozen_string_literal: true

require 'que/view'

Rails.application.routes.draw do
  mount Emailbutler::Engine => '/emailbutler'
  mount PgHero::Engine, at: 'pghero'
  mount Que::View::Engine => '/que_view'

  get 'auth/:provider/callback', to: 'users/omniauth_callbacks#create'

  namespace :admin do
    get '', to: 'welcome#index'

    resources :banned_emails, only: %i[index new create destroy]
    resources :users, only: %i[index]
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
    resources :cups, only: %i[index new create] do
      scope module: :cups do
        resources :rounds, only: %i[index new create]
      end
    end
    resources :cups_rounds, only: %i[] do
      scope module: :cups do
        resources :pairs, only: %i[index new edit create update]
      end
    end
    scope module: :cups do
      get 'cups_rounds/:cups_round_id/refresh_oraculs_points', to: 'rounds#refresh_oraculs_points',
                                                               as: :refresh_oraculs_points
    end
    resources :weeks, only: %i[index edit update]
  end

  scope '(:locale)', locale: /#{I18n.available_locales.join('|')}/, defaults: { locale: nil } do
    namespace :api do
      namespace :v1 do
        namespace :users do
          resources :me, only: %i[index]
          resource :access_tokens, only: %i[create]
        end
        resources :users, only: %i[create]
        resources :leagues, only: %i[index]
        resources :seasons, only: %i[index]
        resources :weeks, only: %i[show]
        resources :games, only: %i[index]
        resources :cups, only: %i[index]
        namespace :cups do
          resources :rounds, only: %i[show]
          resources :pairs, only: %i[index]
        end
        resources :oracul_places, only: %i[index]
        resources :oraculs, only: %i[index]
        namespace :oraculs do
          resource :lineup, only: %i[show]
          resources :forecasts, only: %i[update]
        end
      end

      namespace :frontend do
        resource :notifications, only: %i[create destroy]
        resource :feedback, only: %i[create]
        resource :oraculs, only: %i[create] do
          scope module: :oraculs do
            resources :forecasts, only: %i[index update]
          end
        end
        resources :fantasy_teams, only: %i[destroy] do
          scope module: :fantasy_teams do
            resources :fantasy_leagues, only: %i[index create]
            resources :players, only: %i[index]
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
        resource :cups, only: %i[] do
          resources :rounds, only: %i[show], module: 'cups'
        end
      end
    end

    namespace :users do
      get 'sign-up', to: 'registrations#new'
      post 'sign-up', to: 'registrations#create'
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

    resource :profile, only: %i[show]
    namespace :profile do
      resources :achievements, only: %i[index]
    end

    resource :draft_players, only: %i[show]
    resource :oracul_places, only: %i[show]
    resources :fantasy_teams, only: %i[show create update] do
      scope module: :fantasy_teams do
        resource :transfers, only: %i[show update]
        resources :status, only: %i[index]
        resources :points, only: %i[index]
      end
    end
    resources :oraculs, only: %i[show]
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
    resources :oracul_leagues, only: %i[show]
    resources :rules, only: %i[index]
    resources :lineups, only: %i[show update]
    resources :games, only: %i[] do
      resources :statistics, only: %i[index], module: 'games'
    end
    resources :achievement_groups, only: %i[index]
    resources :achievements, only: %i[index]
    resources :fantasy_cups, only: %i[show]
    resources :identities, only: %i[destroy]

    get 'privacy', to: 'welcome#privacy'

    root 'welcome#index'
  end
end
