# frozen_string_literal: true

module Seasons
  class PlayersController < ApplicationController
    skip_before_action :authenticate, only: %i[index]
    before_action :find_season_players

    def index
      render json: {
        season_players: Teams::PlayerSerializer.new(@season_players).serializable_hash
      }, status: :ok
    end

    private

    def find_season_players
      @season_players = Season.active.find(params[:season_id]).active_teams_players.includes(:seasons_team, :player)
    end
  end
end
