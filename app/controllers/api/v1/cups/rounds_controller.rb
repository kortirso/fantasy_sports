# frozen_string_literal: true

module Api
  module V1
    module Cups
      class RoundsController < Api::V1Controller
        before_action :find_cups_round, only: %i[show]

        SERIALIZER_FIELDS = %w[id position].freeze

        def show
          render json: {
            cups_round: ::Cups::RoundSerializer.new(
              @cups_round, params: serializer_fields(::Cups::RoundSerializer, SERIALIZER_FIELDS)
            ).serializable_hash
          }, status: :ok
        end

        private

        def find_cups_round
          @cups_round = ::Cups::Round.find(params[:id])
        end
      end
    end
  end
end
