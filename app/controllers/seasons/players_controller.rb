# frozen_string_literal: true

module Seasons
  class PlayersController < ApplicationController
    include Cacheable

    skip_before_action :authenticate
    skip_before_action :check_email_confirmation
    before_action :find_season_players
    before_action :find_season_player, only: %i[show]

    def index
      render json: { season_players: season_players_json_response }, status: :ok
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

    def season_players_json_response
      cached_response(payload: @season_players, name: :season_players, version: :v1) do
        Teams::PlayerSerializer.new(@season_players).serializable_hash
      end
    end
  end
end
