# frozen_string_literal: true

module Lineups
  module Players
    module Points
      class UpdateService
        # Updates points for lineups players (only for specific teams players)
        prepend ApplicationService

        def initialize(
          lineups_update_points_service: Lineups::UpdatePointsService
        )
          @lineups_update_points_service = lineups_update_points_service
        end

        def call(team_player_ids:, week_id:)
          lineup_ids = []
          team_player_ids.each do |teams_player_id|
            lineups_players =
              Lineups::Player
              .joins(:lineup)
              .where(teams_player_id: teams_player_id)
              .where(lineups: { week_id: week_id })

            points =
              Games::Player
              .joins(:game)
              .where(teams_player_id: teams_player_id)
              .where(game: { week_id: week_id })
              .sum(:points)

            lineups_players.update_all(points: points)
            lineup_ids.push(lineups_players.pluck(:lineup_id))
          end
          @lineups_update_points_service.call(lineup_ids: lineup_ids.flatten.uniq.sort)
        end
      end
    end
  end
end
