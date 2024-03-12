# frozen_string_literal: true

module Api
  module V1
    class LeaguesController < Api::V1Controller
      SERIALIZER_FIELDS = %w[background_url sport_kind].freeze

      def index
        render json: { leagues: leagues }, status: :ok
      end

      private

      def leagues
        serializer_fields = serializer_fields(LeagueSerializer, SERIALIZER_FIELDS)
        Rails.cache.fetch(
          ['api_v1_leagues_index_v1', serializer_fields],
          expires_in: 24.hours,
          race_condition_ttl: 10.seconds
        ) do
          LeagueSerializer.new(League.order(id: :desc), params: serializer_fields).serializable_hash
        end
      end
    end
  end
end
