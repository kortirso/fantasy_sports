# frozen_string_literal: true

module Admin
  module Seasons
    module Games
      class StatisticsController < AdminController
        before_action :find_game

        def index
          games_players = @game.games_players.includes(teams_player: :player)

          @home_games_players = games_players.where(teams_players: { seasons_team_id: @game.home_season_team_id })
          @visitor_games_players = games_players.where(teams_players: { seasons_team_id: @game.visitor_season_team_id })
          @statistic = ::Statable::SPORT_STATS[@season.league.sport_kind]
        end

        def create
          ::Games::UpdateOperation.call(game: @game, game_data: game_data)
          redirect_to admin_season_games_path(@season.uuid)
        end

        private

        def find_game
          @season = Season.find_by!(uuid: params[:season_id])
          @game = @season.games.find_by!(uuid: params[:game_id])
        end

        def game_data
          result = params.permit(game_data: {})[:game_data].to_h.values

          [
            {
              points: nil,
              players: result[0]
            },
            {
              points: nil,
              players: result[1]
            }
          ]
        end
      end
    end
  end
end
