# frozen_string_literal: true

class WeeksController < ApplicationController
  before_action :find_week, only: %i[show]

  def show
    render json: { week: week }, status: :ok
  end

  private

  def find_week
    @week = Week.find_by!(uuid: params[:id])
  end

  def week
    Rails.cache.fetch(
      [(request_fields ? request_fields.join(',') : :week), 'show_v2', @week.id, @week.updated_at],
      expires_in: 12.hours,
      race_condition_ttl: 10.seconds
    ) do
      WeekSerializer.new(@week, { params: { fields: request_fields } }).serializable_hash
    end
  end
end
