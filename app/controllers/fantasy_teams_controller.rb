# frozen_string_literal: true

class FantasyTeamsController < ApplicationController
  before_action :find_fantasy_team, only: %i[show update]
  before_action :find_fantasy_team_relationships, only: %i[show]
  before_action :find_season, only: %i[create]

  def show; end

  def create
    service_call = FantasyTeams::CreateService.call(season: @season, user: Current.user)
    if service_call.success?
      redirect_to(
        fantasy_team_transfers_path(service_call.result.uuid),
        notice: t('controllers.fantasy_teams.success_create')
      )
    else
      redirect_to home_path, alert: service_call.errors
    end
  end

  def update
    service_call = FantasyTeams::CompleteService.call(
      fantasy_team:      @fantasy_team,
      params:            fantasy_team_params,
      teams_players_ids: params[:fantasy_team][:teams_players_ids]
    )
    if service_call.success?
      render json: { redirect_path: fantasy_team_path(@fantasy_team.uuid) }, status: :ok
    else
      json_response_with_errors(service_call.errors, 422)
    end
  end

  private

  def find_fantasy_team
    @fantasy_team = Current.user.fantasy_teams.find_by(uuid: params[:id])
    page_not_found if @fantasy_team.nil?
  end

  def find_fantasy_team_relationships
    @lineup = @fantasy_team.lineups.joins(:week).where(weeks: { status: Week::COMING }).first
    @season = @fantasy_team.fantasy_leagues.first.season
  end

  def find_season
    @season = Season.active.find(params[:season_id])
  end

  def fantasy_team_params
    params.require(:fantasy_team).permit(:name, :budget_cents)
  end
end
