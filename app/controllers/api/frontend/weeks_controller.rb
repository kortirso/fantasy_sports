# frozen_string_literal: true

module Api
  module Frontend
    class WeeksController < ApplicationController
      before_action :find_week, only: %i[show]

      def show
        render json: { week: week }, status: :ok
      end

      private

      def find_week
        @week = Week.find(params[:id])
      end

      def week
        Rails.cache.fetch(
          ['api_frontend_weeks_show_v1', @week.id, @week.updated_at],
          expires_in: 12.hours,
          race_condition_ttl: 10.seconds
        ) do
          WeekSerializer.new(
            @week, { params: { include_fields: %w[id position deadline_at previous_id next_id] } }
          ).serializable_hash
        end
      end
    end
  end
end
