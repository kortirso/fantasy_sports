# frozen_string_literal: true

module FantasyTeams
  class TransfersController < ApplicationController
    include Maintenable

    before_action :find_fantasy_team
    before_action :find_season, only: %i[show]
    before_action :check_league_maintenance, only: %i[show]
    before_action :find_league, only: %i[update]
    before_action :validate_league_maintenance, only: %i[update]

    def show; end

    def update
      service_call = FantasyTeams::Transfers::PerformService.call(
        fantasy_team: @fantasy_team,
        teams_players_ids: Teams::Player.where(uuid: params[:fantasy_team][:teams_players_uuids]).ids,
        only_validate: params[:fantasy_team][:only_validate]
      )
      if service_call.success?
        render json: { result: service_call.result }, status: :ok
      else
        json_response_with_errors(service_call.errors, 422)
      end
    end

    private

    def find_fantasy_team
      @fantasy_team = Current.user.fantasy_teams.find_by!(uuid: params[:fantasy_team_id])
    end

    def find_season
      @season = @fantasy_team.fantasy_leagues.first.season
    end

    def find_league
      @league = @fantasy_team.fantasy_leagues.first.season.league
    end
  end
end
