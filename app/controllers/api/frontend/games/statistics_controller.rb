# frozen_string_literal: true

module Api
  module Frontend
    module Games
      class StatisticsController < ApplicationController
        before_action :find_game

        def index
          render json: { game: game_json_response }, status: :ok
        end

        private

        def find_game
          @game = Game.find(params[:game_id])
        end

        def game_json_response
          Rails.cache.fetch(
            ['api_frontend_games_statistics_index_v1', @game.id, @game.updated_at],
            expires_in: 24.hours,
            race_condition_ttl: 10.seconds
          ) do
            ::Games::StatisticsService.call(game: @game).result
          end
        end
      end
    end
  end
end
