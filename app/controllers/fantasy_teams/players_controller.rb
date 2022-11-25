# frozen_string_literal: true

module FantasyTeams
  class PlayersController < ApplicationController
    include Cacheable

    before_action :find_fantasy_team
    before_action :find_fantasy_team_players

    def index
      render json: { teams_players: teams_players_json_response }, status: :ok
    end

    private

    def find_fantasy_team
      @fantasy_team = Current.user.fantasy_teams.find_by!(uuid: params[:fantasy_team_id])
    end

    def find_fantasy_team_players
      @teams_players = @fantasy_team.teams_players.active.includes(:player, seasons_team: :team)
    end

    def teams_players_json_response
      cached_response(payload: @teams_players, name: :teams_players, version: :v1) do
        Teams::PlayerSerializer.new(@teams_players).serializable_hash
      end
    end
  end
end
