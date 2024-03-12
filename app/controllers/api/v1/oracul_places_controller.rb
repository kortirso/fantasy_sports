# frozen_string_literal: true

module Api
  module V1
    class OraculPlacesController < Api::V1Controller
      SERIALIZER_FIELDS = %w[name placeable_id placeable_type].freeze

      def index
        render json: { oracul_places: oracul_places }, status: :ok
      end

      private

      def oracul_places
        serializer_fields = serializer_fields(OraculPlaceSerializer, SERIALIZER_FIELDS)
        Rails.cache.fetch(
          ['api_v1_oracul_places_index_v1', serializer_fields],
          expires_in: 24.hours,
          race_condition_ttl: 10.seconds
        ) do
          OraculPlaceSerializer.new(OraculPlace.active.order(id: :desc), params: serializer_fields).serializable_hash
        end
      end
    end
  end
end
