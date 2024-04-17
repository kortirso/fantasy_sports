# frozen_string_literal: true

module Api
  module V1
    class SeasonsController < Api::V1Controller
      SERIALIZER_FIELDS = %w[name league_id].freeze

      def index
        render json: { seasons: seasons }, status: :ok
      end

      private

      def seasons
        serializer_fields = serializer_fields(SeasonSerializer, SERIALIZER_FIELDS)
        Rails.cache.fetch(
          ['api_v1_seasons_index_v1', serializer_fields],
          expires_in: 24.hours,
          race_condition_ttl: 10.seconds
        ) do
          SeasonSerializer.new(Season.in_progress.order(id: :desc), params: serializer_fields).serializable_hash
        end
      end
    end
  end
end
