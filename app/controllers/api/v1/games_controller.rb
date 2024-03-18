# frozen_string_literal: true

module Api
  module V1
    class GamesController < Api::V1Controller
      include Deps[games_query: 'queries.games']

      before_action :find_games, only: %i[index]

      SERIALIZER_FIELDS = %w[id points predictable start_at home_name visitor_name].freeze

      def index
        render json: {
          games: GameSerializer.new(
            @games, params: serializer_fields(GameSerializer, SERIALIZER_FIELDS)
          ).serializable_hash
        }, status: :ok
      end

      private

      def find_games
        @games = games_query.resolve(params: params).order(start_at: :asc)

        response_include_fields = params[:response_include_fields]
        @games = @games.includes(home_season_team: :team) if response_include_fields&.include?('home_team')
        @games = @games.includes(visitor_season_team: :team) if response_include_fields&.include?('visitor_team')
      end
    end
  end
end
