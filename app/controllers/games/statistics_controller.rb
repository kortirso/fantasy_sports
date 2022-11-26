# frozen_string_literal: true

module Games
  class StatisticsController < ApplicationController
    include Cacheable

    before_action :find_game

    def index
      render json: { game: game_json_response }, status: :ok
    end

    private

    def find_game
      @game = Game.find_by!(uuid: params[:game_id])
    end

    def game_json_response
      cached_response(payload: @game, name: :game_statistics, version: :v1) do
        Games::StatisticsService.call(game: @game).result
      end
    end
  end
end
