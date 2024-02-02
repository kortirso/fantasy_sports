# frozen_string_literal: true

module Api
  module Frontend
    module Lineups
      class PlayersController < ApplicationController
        before_action :find_lineup, only: %i[show]

        def show
          render json: { lineup_players: lineup_players }, status: :ok
        end

        private

        def find_lineup
          @lineup =
            Lineup
              .joins(:week, fantasy_team: :user)
              .where('weeks.status IN (2, 3) OR users.id = ?', Current.user.id)
              .find_by!(uuid: params[:lineup_id])
        end

        def lineup_players
          Rails.cache.fetch(
            ['api_frontend_lineups_players_show_v2', @lineup.id, @lineup.updated_at, params[:fields]],
            expires_in: 12.hours,
            race_condition_ttl: 10.seconds
          ) do
            ::Lineups::PlayerSerializer.new(
              @lineup
                .lineups_players
                .includes(:lineup, teams_player: [:players_season, :player, { seasons_team: :team }]),
              params: {
                injuries: injuries,
                games_players: games_players,
                last_points: last_points,
                fields: request_fields
              }
            ).serializable_hash
          end
        end

        def injuries
          @lineup.week.season.injuries.active.group_by(&:players_season_id)
        end

        def games_players
          return if params[:fields].blank?
          return if params[:fields].exclude?('week_statistic')

          @lineup
            .week
            .games_players
            .where(teams_player_id: teams_players_ids)
            .hashable_pluck(:teams_player_id, :statistic)
            .group_by { |e| e[:teams_player_id] }
        end

        def last_points
          return if params[:fields].blank?
          return if params[:fields].exclude?('last_points')

          lineup =
            Lineup
              .joins(:week)
              .find_by(weeks: { season_id: @lineup.week.season_id, position: @lineup.week.position - 1 })
          return unless lineup

          lineup.lineups_players.hashable_pluck(:teams_player_id, :points, :status)
        end

        def teams_players_ids
          @lineup.lineups_players.select(:teams_player_id)
        end
      end
    end
  end
end
