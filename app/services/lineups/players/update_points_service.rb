# frozen_string_literal: true

module Lineups
  module Players
    class UpdatePointsService
      prepend ApplicationService

      def initialize(
        lineups_update_points_service: Lineups::UpdatePointsService
      )
        @lineups_update_points_service = lineups_update_points_service
      end

      def call(teams_players_points:, week_id:)
        lineup_ids = []
        teams_players_points.each do |id, points|
          lineups_players =
            Lineups::Player.joins(lineup: :week)
            .where(teams_player_id: Teams::Player.where(id: id))
            .where(weeks: { id: week_id })

          lineups_players.update_all(points: points)
          lineup_ids.push(lineups_players.pluck(:lineup_id))
        end
        @lineups_update_points_service.call(lineup_ids: lineup_ids.flatten.uniq.sort)
      end
    end
  end
end
