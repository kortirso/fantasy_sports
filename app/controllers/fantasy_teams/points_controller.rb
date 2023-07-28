# frozen_string_literal: true

module FantasyTeams
  class PointsController < ApplicationController
    include Maintenable

    before_action :find_fantasy_team
    before_action :find_week
    before_action :find_fantasy_team_relationships
    before_action :check_league_maintenance

    def index; end

    private

    def find_fantasy_team
      @fantasy_team = FantasyTeam.find_by!(uuid: params[:fantasy_team_id])
    end

    def find_week
      @week = @fantasy_team.weeks
      @week = params[:week] ? @week.opponent_visible.find_by!(position: params[:week]) : @week.active.first
    end

    def find_fantasy_team_relationships
      @lineup = Lineup.find_by!(fantasy_team: @fantasy_team, week: @week)
      @season = @fantasy_team.fantasy_leagues.first.season if @lineup
    end
  end
end
