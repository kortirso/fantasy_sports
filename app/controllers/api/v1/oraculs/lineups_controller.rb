# frozen_string_literal: true

module Api
  module V1
    module Oraculs
      class LineupsController < Api::V1Controller
        before_action :find_oracul, only: %i[show]
        before_action :find_periodable, only: %i[show]
        before_action :find_oraculs_lineup, only: %i[show]

        SERIALIZER_FIELDS = %w[id periodable_id periodable_type].freeze

        def show
          render json: {
            oraculs_lineup: ::Oraculs::LineupSerializer.new(
              @oraculs_lineup, params: serializer_fields(::Oraculs::LineupSerializer, SERIALIZER_FIELDS).merge({
                owner: @oracul.user_id == current_user.id,
                periodable: @periodable
              })
            ).serializable_hash
          }, status: :ok
        end

        private

        def find_oracul
          @oracul = Oracul.find(params[:oracul_id])
        end

        def find_periodable
          placeable = @oracul.oracul_place.placeable
          relation = @oracul.oracul_place.season? ? placeable.weeks : placeable.cups_rounds
          @periodable = params[:week_id] ? relation.find(params[:week_id]) : (relation.active.first || relation.first)
        end

        def find_oraculs_lineup
          @oraculs_lineup = @oracul.oraculs_lineups.find_by(periodable: @periodable)
        end
      end
    end
  end
end
