# frozen_string_literal: true

module FantasyTeams
  class TransfersController < ApplicationController
    include Maintenable

    before_action :find_fantasy_team
    before_action :find_season, only: %i[show]
    before_action :validate_season_finishing, only: %i[show]
    before_action :find_lineup, only: %i[show]
    before_action :check_season_maintenance, only: %i[show]
    before_action :set_watchable_players, only: %i[show]
    before_action :validate_season_maintenance, only: %i[update]

    def show; end

    def update
      service_call = FantasyTeams::Transfers::PerformService.call(
        fantasy_team: @fantasy_team,
        teams_players_ids: Teams::Player.where(
          players_season_id: ::Players::Season.where(uuid: params[:fantasy_team][:players_seasons_uuids]).select(:id)
        ).ids,
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
      @season = @fantasy_team.season
    end

    def validate_season_finishing
      return if @season.open_transfers?

      page_not_found
    end

    def find_lineup
      @lineup = @fantasy_team.lineups.joins(:week).where(weeks: { status: Week::COMING }).first
    end
  end
end
