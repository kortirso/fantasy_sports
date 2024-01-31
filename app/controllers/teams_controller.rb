# frozen_string_literal: true

class TeamsController < ApplicationController
  skip_before_action :authenticate, only: %i[index]
  before_action :find_teams, only: %i[index]

  def index
    render json: { teams: teams }, status: :ok
  end

  private

  def find_teams
    @teams = Season.active.find_by!(uuid: params[:season_uuid]).teams
  end

  def teams
    Rails.cache.fetch(
      ['teams_index_v1', @teams.maximum(:updated_at)],
      expires_in: 12.hours,
      race_condition_ttl: 10.seconds
    ) do
      TeamSerializer.new(@teams).serializable_hash
    end
  end
end
