# frozen_string_literal: true

module FantasyTeams
  class PointsController < ApplicationController
    include Maintenable

    before_action :find_fantasy_team
    before_action :find_fantasy_team_relationships
    before_action :check_league_maintenance

    def index; end

    private

    def find_fantasy_team
      @fantasy_team = Current.user.fantasy_teams.find_by(uuid: params[:fantasy_team_id])
      page_not_found if @fantasy_team.nil?
    end

    def find_fantasy_team_relationships
      @lineup = @fantasy_team.lineups.joins(:week).where(weeks: { status: Week::ACTIVE }).first
      @season = @fantasy_team.fantasy_leagues.first.season if @lineup
    end
  end
end
