# frozen_string_literal: true

class FantasyTeamsController < ApplicationController
  before_action :find_fantasy_team, only: %i[show update]
  before_action :find_leagues_season, only: %i[create]

  def show; end

  def create
    service_call = FantasyTeams::CreateService.call(season: @season, user: Current.user)
    if service_call.success?
      flash[:notice] = t('controllers.fantasy_teams.success_create')
      redirect_to fantasy_team_path(id: service_call.result.uuid)
    else
      flash[:alert] = service_call.errors
      redirect_to home_path
    end
  end

  def update
    service_call = FantasyTeams::UpdateService.call(fantasy_team: @fantasy_team, params: fantasy_team_params)
    if service_call.success?
      render json: { redirect_path: fantasy_team_path(@fantasy_team.uuid) }, status: :ok
    else
      render json: { errors: service_call.errors }, status: :unprocessable_entity
    end
  end

  private

  def find_fantasy_team
    @fantasy_team = FantasyTeam.find_by(uuid: params[:id])
    @season = @fantasy_team.fantasy_leagues.first.leagues_season
  end

  def find_leagues_season
    @season = Leagues::Season.active.find_by(id: params[:season_id])
  end

  def fantasy_team_params
    params.require(:fantasy_team).permit(:name, teams_players_ids: [])
  end
end
