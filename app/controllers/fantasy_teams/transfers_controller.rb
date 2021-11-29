# frozen_string_literal: true

module FantasyTeams
  class TransfersController < ApplicationController
    before_action :find_fantasy_team

    def index; end

    private

    def find_fantasy_team
      @fantasy_team = Current.user.fantasy_teams.find_by(uuid: params[:fantasy_team_id])
      @season = @fantasy_team.fantasy_leagues.first.leagues_season
    end
  end
end
