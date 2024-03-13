# frozen_string_literal: true

module Api
  module V1
    class OraculsController < Api::V1Controller
      SERIALIZER_FIELDS = %w[uuid name oracul_place_id].freeze

      def index
        render json: { oraculs: oraculs }, status: :ok
      end

      private

      def oraculs
        OraculSerializer.new(
          Current.user.oraculs.order(id: :desc), params: serializer_fields(OraculSerializer, SERIALIZER_FIELDS)
        ).serializable_hash
      end
    end
  end
end
