# frozen_string_literal: true

module Api
  module Frontend
    class GamesController < ApplicationController
      include Deps[games_query: 'queries.games']

      before_action :find_games, only: %i[index]

      def index
        render json: {
          games: GameSerializer.new(
            @games, params: { include_fields: %w[id points predictable start_at home_team visitor_team] }
          ).serializable_hash
        }, status: :ok
      end

      private

      def find_games
        @games = games_query.resolve(params: params).includes(home_season_team: :team, visitor_season_team: :team)
      end
    end
  end
end
