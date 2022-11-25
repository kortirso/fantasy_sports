# frozen_string_literal: true

class WeeksController < ApplicationController
  include Cacheable

  def show
    render json: { week: week_json_response }, status: :ok
  end

  private

  def week
    @week = Week
    if request_fields&.include?('games')
      @week = @week.includes(games: [home_season_team: :team, visitor_season_team: :team])
    end
    @week = @week.find_by!(uuid: params[:id])
  end

  def week_json_response
    cached_response(
      payload: Week.find_by!(uuid: params[:id]),
      name: (request_fields ? request_fields.join(',') : :week),
      version: :v1
    ) do
      WeekSerializer.new(week, { params: { fields: request_fields } }).serializable_hash
    end
  end
end
