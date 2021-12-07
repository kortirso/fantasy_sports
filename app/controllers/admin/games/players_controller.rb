# frozen_string_literal: true

module Admin
  module Games
    class PlayersController < AdminController
      before_action :find_game

      def update
        ::Games::StatisticService.call(game: @game, games_players_statistic: games_players_statistic)
      end

      private

      def find_game
        @game = Game.find(params[:game_id])
      end

      def games_players_statistic
        params.permit(games_players: {})[:games_players].to_h
      end
    end
  end
end
