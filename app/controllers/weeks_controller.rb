# frozen_string_literal: true

class WeeksController < ApplicationController
  include Cacheable

  before_action :find_week

  def show
    render json: { week: week_json_response }, status: :ok
  end

  private

  def find_week
    @week = Week.find_by!(uuid: params[:id])
  end

  def week_json_response
    cached_response(
      payload: @week,
      name: (request_fields ? request_fields.join(',') : :week),
      version: :v1
    ) do
      WeekSerializer.new(@week, { params: { fields: request_fields } }).serializable_hash
    end
  end
end
