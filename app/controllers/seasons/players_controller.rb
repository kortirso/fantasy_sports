# frozen_string_literal: true

module Seasons
  class PlayersController < ApplicationController
    before_action :find_season_players
    before_action :find_season_player, only: %i[show]

    def index
      render json: { season_players: season_players_json_response }, status: :ok
    end

    def show
      render json: { season_player: season_player_json_response }, status: :ok
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
      Rails.cache.fetch(
        ['seasons_players_index_v1', @season_players.maximum(:updated_at)],
        expires_in: 6.hours,
        race_condition_ttl: 10.seconds
      ) do
        Teams::PlayerSerializer.new(@season_players).serializable_hash
      end
    end

    def season_player_json_response
      Rails.cache.fetch(
        ['seasons_players_show_v1', @season_player.id, @season_player.updated_at],
        expires_in: 12.hours,
        race_condition_ttl: 10.seconds
      ) do
        Controllers::Seasons::Players::ShowSerializer.new(@season_player).serializable_hash
      end
    end
  end
end
