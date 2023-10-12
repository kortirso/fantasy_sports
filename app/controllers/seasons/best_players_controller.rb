# frozen_string_literal: true

module Seasons
  class BestPlayersController < ApplicationController
    include Deps[find_best_service: 'services.players.find_best']

    before_action :find_season, only: %i[index]

    def index
      render json: find_best_players, status: :ok
    end

    private

    def find_season
      @season = Season.active.find_by!(uuid: params[:season_id])
    end

    def find_best_players
      call = find_best_service.call(season: @season, week_uuid: params[:week_uuid])
      return [] if call[:ids].empty?

      call[:output].map do |element|
        [
          Controllers::Seasons::BestPlayers::IndexSerializer
            .new(teams_players(call[:ids]).find { |e| e.id == element[0] })
            .serializable_hash,
          element[1]
        ]
      end
    end

    def teams_players(ids)
      @teams_players ||= Teams::Player.where(id: ids).includes(:player, seasons_team: :team)
    end
  end
end
