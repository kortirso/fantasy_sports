# frozen_string_literal: true

module Seasons
  class BestPlayersController < ApplicationController
    include Deps[find_best_service: 'services.players.find_best']

    before_action :find_season, only: %i[index]
    before_action :find_week, only: %i[index]

    def index
      render json: best_players, status: :ok
    end

    private

    def find_season
      @season = Season.active.find_by!(uuid: params[:season_id])
    end

    def find_week
      @week = params[:week_uuid] ? @season.weeks.find_by(uuid: params[:week_uuid]) : nil
    end

    # rubocop: disable Metrics/AbcSize
    def best_players
      Rails.cache.fetch(cache_key, expires_in: 4.hours, race_condition_ttl: 10.seconds) do
        call = find_best_service.call(season: @season, week_id: @week&.id)
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
    end
    # rubocop: enable Metrics/AbcSize

    def cache_key
      return ['seasons_week_best_players_index_v1', @week.id, @week.updated_at] if @week

      ['seasons_best_players_index_v1', @season.id, @season.weeks.maximum(:updated_at)]
    end

    def teams_players(ids)
      @teams_players ||= Teams::Player.where(id: ids).includes(:player, seasons_team: :team)
    end
  end
end
