# frozen_string_literal: true

module Admin
  module Seasons
    module Games
      class StatisticsController < AdminController
        before_action :find_game

        def index
          @games_players = @game.games_players.includes(teams_player: :player)
          @statistic = ::Statable::SPORT_STATS[@season.league.sport_kind]
        end

        def create
          ::Games::UpdateDataService.call(game: @game, game_data: game_data)
          redirect_to admin_season_games_path(@season.uuid)
        end

        private

        def find_game
          @season = Season.find_by!(uuid: params[:season_id])
          @game = @season.games.find_by!(uuid: params[:game_id])
        end

        def game_data
          params.permit(game_data: {})[:game_data].to_h.values.map { |e| e.transform_keys(&:to_i) }
        end
      end
    end
  end
end