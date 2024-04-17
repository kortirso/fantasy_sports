# frozen_string_literal: true

class FantasyTeamsController < ApplicationController
  include Deps[join_fantasy_league: 'services.persisters.fantasy_teams.join_fantasy_league']
  include Maintenable

  before_action :find_fantasy_team, only: %i[show update]
  before_action :find_fantasy_team_relationships, only: %i[show]
  before_action :find_season, only: %i[create]
  before_action :check_season_maintenance, only: %i[show]
  before_action :set_watchable_players, only: %i[show]
  before_action :validate_season_maintenance, only: %i[update]

  def show; end

  def create
    service_call = FantasyTeams::CreateService.call(season: @season, user: Current.user)
    if service_call.success?
      join_fantasy_league.call(fantasy_team: service_call.result, invite_code: cookies[:fantasy_sports_invite_code])
      redirect_to(
        fantasy_team_transfers_path(service_call.result.uuid),
        notice: t('controllers.fantasy_teams.success_create')
      )
    else
      redirect_to draft_players_path, alert: service_call.errors
    end
  end

  def update
    service_call = FantasyTeams::CompleteService.call(
      fantasy_team: @fantasy_team,
      params: fantasy_team_params,
      teams_players_ids: Teams::Player.where(
        players_season_id: ::Players::Season.where(uuid: params[:fantasy_team][:players_seasons_uuids]).select(:id)
      ).ids
    )
    if service_call.success?
      render json: { redirect_path: fantasy_team_path(@fantasy_team.uuid) }, status: :ok
    else
      json_response_with_errors(service_call.errors, 422)
    end
  end

  private

  def find_fantasy_team
    @fantasy_team = Current.user.fantasy_teams.find_by!(uuid: params[:id])
  end

  def find_fantasy_team_relationships
    @lineup = @fantasy_team.lineups.joins(:week).where(weeks: { status: Week::COMING }).first
    @season = @fantasy_team.season
  end

  def find_season
    @season = Season.in_progress.find_by!(uuid: params[:season_id])
  end

  def fantasy_team_params
    params.require(:fantasy_team).permit(:name, :favourite_team_uuid)
  end
end
