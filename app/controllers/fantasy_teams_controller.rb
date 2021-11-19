# frozen_string_literal: true

class FantasyTeamsController < ApplicationController
  before_action :find_fantasy_team, only: %i[show]
  before_action :find_league, only: %i[create]

  def show; end

  def create
    service_call = FantasyTeams::CreateService.call(league: @league, user: Current.user)
    if service_call.success?
      flash[:notice] = 'Fantasy team is created'
      redirect_to fantasy_team_path(id: service_call.result.uuid)
    else
      flash[:alert] = service_call.errors
      redirect_to home_path
    end
  end

  private

  def find_fantasy_team
    @fantasy_team = FantasyTeam.find_by(uuid: params[:id])
  end

  def find_league
    @league = League.find_by(id: params[:league_id])
  end
end
