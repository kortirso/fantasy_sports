# frozen_string_literal: true

module Sports
  class PositionsController < ApplicationController
    skip_before_action :authenticate, only: %i[index]
    before_action :find_sports_positions

    def index
      render json: {
        sports_positions: Sports::PositionSerializer.new(
          @sports_positions,
          { params: { fields: request_fields } }
        ).serializable_hash
      }, status: :ok
    end

    private

    def find_sports_positions
      @sports_positions = League.find(params[:league_id]).sport.sports_positions.order(id: :asc)
    end
  end
end
