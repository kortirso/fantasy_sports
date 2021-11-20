# frozen_string_literal: true

module Teams
  class PlayersController < ApplicationController
    skip_before_action :authenticate, only: %i[index]
    before_action :find_teams_players

    def index
      render json: {
        teams_players: Teams::PlayerSerializer.new(@teams_players).serializable_hash
      }, status: :ok
    end

    private

    def find_teams_players
      @teams_players = League.find(params[:league_id]).active_season.active_teams_players.includes(:leagues_seasons_team, :player)
    end
  end
end
