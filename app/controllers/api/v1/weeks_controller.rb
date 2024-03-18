# frozen_string_literal: true

module Api
  module V1
    class WeeksController < Api::V1Controller
      before_action :find_week, only: %i[show]

      SERIALIZER_FIELDS = %w[id position].freeze

      def show
        render json: {
          week: WeekSerializer.new(
            @week, params: serializer_fields(WeekSerializer, SERIALIZER_FIELDS)
          ).serializable_hash
        }, status: :ok
      end

      private

      def find_week
        @week = Week.find(params[:id])
      end
    end
  end
end
