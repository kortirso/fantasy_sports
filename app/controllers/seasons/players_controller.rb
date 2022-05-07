# frozen_string_literal: true

module Seasons
  class PlayersController < ApplicationController
    skip_before_action :authenticate
    before_action :find_season_players
    before_action :find_season_player, only: %i[show]

    def index
      render json: {
        season_players: Teams::PlayerSerializer.new(
          @season_players,
          { params: { fields: request_fields } }
        ).serializable_hash
      }, status: :ok
    end

    def show
      render json: {
        season_player: Teams::PlayerSerializer.new(
          @season_player,
          { params: { fields: request_fields } }
        ).serializable_hash
      }, status: :ok
    end

    private

    def find_season_players
      @season_players =
        Season.active.find(params[:season_id]).active_teams_players.includes(:seasons_team, :player)
    end

    def find_season_player
      @season_player = @season_players.find(params[:id])
    end
  end
end
