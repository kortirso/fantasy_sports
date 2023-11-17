# frozen_string_literal: true

module FantasyTeams
  class PointsController < ApplicationController
    include Maintenable

    before_action :find_fantasy_team
    before_action :find_week
    before_action :find_fantasy_team_relationships
    before_action :calculate_lineups_data
    before_action :check_league_maintenance

    def index; end

    private

    def find_fantasy_team
      @fantasy_team = FantasyTeam.find_by!(uuid: params[:fantasy_team_id])
    end

    def find_week
      weeks = @fantasy_team.weeks
      @week = params[:week] ? weeks.opponent_visible.find_by!(position: params[:week]) : weeks.active.first
      @week = @fantasy_team.season.weeks.active.first if @week.nil?
    end

    def find_fantasy_team_relationships
      @lineup = Lineup.find_by(fantasy_team: @fantasy_team, week: @week)
      @season = @fantasy_team.season
    end

    def calculate_lineups_data
      return if @week.nil?

      @lineups_data = @week.lineups.pluck(:points)
    end
  end
end
