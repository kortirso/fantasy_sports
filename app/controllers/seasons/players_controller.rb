# frozen_string_literal: true

module Seasons
  class PlayersController < ApplicationController
    before_action :find_season
    before_action :find_season_players
    before_action :find_season_player, only: %i[show]

    def index
      render json: { season_players: season_players_json_response }, status: :ok
    end

    def show
      render json: { season_player: season_player_json_response }, status: :ok
    end

    private

    def find_season
      @season = Season.in_progress.find_by!(uuid: params[:season_id])
    end

    def find_season_players
      @season_players = @season.players_seasons
    end

    def find_season_player
      @season_player = @season_players.find_by!(uuid: params[:id])
    end

    def season_players_json_response
      Rails.cache.fetch(
        ['seasons_players_index_v7', @season.id, @season.updated_at, @season_players.maximum(:updated_at)],
        expires_in: 6.hours,
        race_condition_ttl: 10.seconds
      ) do
        ::Players::SeasonSerializer.new(
          @season_players.includes(:player, active_teams_player: [seasons_team: :team]),
          params: { injuries: @season.injuries.active.group_by(&:players_season_id) }
        ).serializable_hash
      end
    end

    def season_player_json_response
      Rails.cache.fetch(
        ['seasons_players_show_v9', @season_player.id, @season_player.updated_at],
        expires_in: 12.hours,
        race_condition_ttl: 10.seconds
      ) do
        ::Controllers::Seasons::Players::ShowSerializer.new(@season_player).serializable_hash
      end
    end
  end
end
