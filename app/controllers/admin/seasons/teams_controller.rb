# frozen_string_literal: true

module Admin
  module Seasons
    class TeamsController < AdminController
      before_action :find_season, only: %i[index show]
      before_action :find_seasons_teams, only: %i[index]
      before_action :find_seasons_team, only: %i[show]
      before_action :find_teams_players, only: %i[show]

      def index; end

      def show; end

      private

      def find_season
        @season = Season.find_by!(uuid: params[:season_id])
      end

      def find_seasons_teams
        @seasons_teams = @season.seasons_teams.includes(:team)
      end

      def find_seasons_team
        @sport_positions = Sports::Position.where(sport: @season.league.sport_kind).pluck(:title, :name).to_h
        @seasons_team = @season.seasons_teams.find_by(id: params[:id])
      end

      def find_teams_players
        @teams_players =
          @seasons_team
            .teams_players
            .where(active: true)
            .includes(:player)
            .sort_by { |teams_player| teams_player.shirt_number_string.to_i }
      end
    end
  end
end
