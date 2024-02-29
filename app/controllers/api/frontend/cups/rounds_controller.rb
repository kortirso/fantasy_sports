# frozen_string_literal: true

module Api
  module Frontend
    module Cups
      class RoundsController < ApplicationController
        before_action :find_cups_round, only: %i[show]

        def show
          render json: { cups_round: cups_round }, status: :ok
        end

        private

        def find_cups_round
          @cups_round = ::Cups::Round.find_by!(uuid: params[:id])
        end

        def cups_round
          Rails.cache.fetch(
            ['api_frontend_cups_rounds_show_v1', @cups_round.id, @cups_round.updated_at],
            expires_in: 12.hours,
            race_condition_ttl: 10.seconds
          ) do
            ::Cups::RoundSerializer.new(@cups_round).serializable_hash
          end
        end
      end
    end
  end
end
