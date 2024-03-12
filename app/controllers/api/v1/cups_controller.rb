# frozen_string_literal: true

module Api
  module V1
    class CupsController < Api::V1Controller
      SERIALIZER_FIELDS = %w[name league_id].freeze

      def index
        render json: { cups: cups }, status: :ok
      end

      private

      def cups
        serializer_fields = serializer_fields(CupSerializer, SERIALIZER_FIELDS)
        Rails.cache.fetch(
          ['api_v1_cups_index_v1', serializer_fields],
          expires_in: 24.hours,
          race_condition_ttl: 10.seconds
        ) do
          CupSerializer.new(Cup.active.order(id: :desc), params: serializer_fields).serializable_hash
        end
      end
    end
  end
end
