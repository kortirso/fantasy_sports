# frozen_string_literal: true

module Api
  module Frontend
    module PlayersSeasons
      class WatchesController < ApplicationController
        before_action :find_players_season, only: %i[create destroy]
        before_action :find_fantasy_team, only: %i[create destroy]
        before_action :find_watch, only: %i[destroy]

        def create
          ::FantasyTeams::Watch.create_or_find_by(
            fantasy_team_id: @fantasy_team.id,
            players_season_id: @players_season.id
          )
          render json: { result: 'ok' }, status: :ok
        end

        def destroy
          @watch.destroy
          render json: { result: 'ok' }, status: :ok
        end

        private

        def find_players_season
          @players_season = Players::Season.find_by!(uuid: params[:players_season_id])
        end

        def find_fantasy_team
          @fantasy_team =
            FantasyTeam.joins(:season).where(seasons: { id: @players_season.season_id }).find_by!(user: Current.user)
        end

        def find_watch
          @watch = ::FantasyTeams::Watch.find_by!(
            fantasy_team_id: @fantasy_team.id,
            players_season_id: @players_season.id
          )
        end
      end
    end
  end
end
