# frozen_string_literal: true

module Api
  module Frontend
    module FantasyTeams
      class FantasyLeaguesController < ApplicationController
        include Deps[create_form: 'forms.fantasy_leagues.create']

        before_action :find_fantasy_team, only: %i[create]

        def create
          form = create_form.call(
            fantasy_team: @fantasy_team,
            leagueable: Current.user,
            params: fantasy_league_params
          )
          case form
          in { errors: errors } then render json: { errors: errors }, status: :ok
          else render json: { errors: [] }, status: :ok
          end
        end

        private

        def find_fantasy_team
          @fantasy_team = Current.user.fantasy_teams.find_by!(uuid: params[:fantasy_team_id])
        end

        def fantasy_league_params
          params.require(:fantasy_league).permit(:name)
        end
      end
    end
  end
end
