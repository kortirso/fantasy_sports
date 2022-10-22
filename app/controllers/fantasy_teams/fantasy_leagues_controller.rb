# frozen_string_literal: true

module FantasyTeams
  class FantasyLeaguesController < ApplicationController
    before_action :find_fantasy_team
    before_action :find_fantasy_leagues

    def index; end

    private

    def find_fantasy_team
      @fantasy_team = Current.user.fantasy_teams.find_by!(uuid: params[:fantasy_team_id])
    end

    def find_fantasy_leagues
      @fantasy_leagues = @fantasy_team.fantasy_leagues
    end
  end
end
