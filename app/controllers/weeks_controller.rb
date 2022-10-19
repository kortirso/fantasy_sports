# frozen_string_literal: true

class WeeksController < ApplicationController
  before_action :find_week

  def show
    render json: {
      week: WeekSerializer.new(
        @week,
        { params: { fields: request_fields } }
      ).serializable_hash
    }, status: :ok
  end

  private

  def find_week
    @week = Week
    if params[:fields]&.split(',')&.include?('games')
      @week = @week.includes(games: %i[home_season_team visitor_season_team])
    end
    @week = @week.find_by!(uuid: params[:id])
  end
end
