# frozen_string_literal: true

module Seasons
  class PlayersController < ApplicationController
    skip_before_action :authenticate
    before_action :find_season_players
    before_action :find_season_player, only: %i[show]

    def index
      render json: {
        season_players: Teams::PlayerSerializer.new(@season_players).serializable_hash
      }, status: :ok
    end

    def show
      render json: {
        season_player: Controllers::Seasons::Players::ShowSerializer.new(@season_player).serializable_hash
      }, status: :ok
    end

    private

    def find_season_players
      @season_players =
        Season.active.find_by!(uuid: params[:season_id]).active_teams_players.includes(:player, seasons_team: :team)
    end

    def find_season_player
      @season_player = @season_players.find_by(uuid: params[:id])
    end
  end
end
