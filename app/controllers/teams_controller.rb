# frozen_string_literal: true

class TeamsController < ApplicationController
  include Cacheable

  skip_before_action :authenticate, only: %i[index]
  skip_before_action :check_email_confirmation, only: %i[index]
  before_action :find_teams

  def index
    render json: { teams: teams_json_response }, status: :ok
  end

  private

  def find_teams
    @teams = Season.active.find_by!(uuid: params[:season_uuid]).teams
  end

  def teams_json_response
    cached_response(payload: @teams, name: :teams, version: :v1) do
      TeamSerializer.new(@teams).serializable_hash
    end
  end
end
