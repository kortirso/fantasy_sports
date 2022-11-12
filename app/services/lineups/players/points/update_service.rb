# frozen_string_literal: true

module Lineups
  module Players
    module Points
      class UpdateService
        # Updates points for lineups players (only for specific teams players)
        prepend ApplicationService

        CAPTAIN_POINTS_COEFFICIENT = 2
        TRIPLE_CAPTAIN_POINTS_COEFFICIENT = 3

        def initialize(
          lineups_update_points_service: Lineups::UpdatePointsService
        )
          @lineups_update_points_service = lineups_update_points_service
        end

        # rubocop: disable Metrics/AbcSize, Metrics/MethodLength
        def call(team_player_ids:, week_id:)
          lineup_ids = []
          team_player_ids.each do |teams_player_id|
            lineups_players =
              Lineups::Player
              .joins(:lineup)
              .where(teams_player_id: teams_player_id)
              .where(lineups: { week_id: week_id })

            games_players =
              Games::Player
              .joins(:game)
              .where(teams_player_id: teams_player_id)
              .where(game: { week_id: week_id })

            points = games_players.sum(:points)
            statistic = games_players.pluck(:statistic).inject({}) { |acc, element|
              acc.merge(element) { |_, oldval, newval| oldval + newval }
            }

            update_captains_points(lineups_players, points, statistic)
            lineups_players.not_captain.update_all(points: points, statistic: statistic)
            lineup_ids.push(lineups_players.pluck(:lineup_id))
          end
          @lineups_update_points_service.call(lineup_ids: lineup_ids.flatten.uniq.sort)
        end
        # rubocop: enable Metrics/AbcSize, Metrics/MethodLength

        def update_captains_points(lineups_players, points, statistic)
          captains = lineups_players.captain.joins(:lineup)
          captains
            .where('lineups.active_chips @> ?', "{#{Chipable::TRIPLE_CAPTAIN}}")
            .update_all(points: points * TRIPLE_CAPTAIN_POINTS_COEFFICIENT, statistic: statistic)
          captains
            .where.not('lineups.active_chips @> ?', "{#{Chipable::TRIPLE_CAPTAIN}}")
            .update_all(points: points * CAPTAIN_POINTS_COEFFICIENT, statistic: statistic)
        end
      end
    end
  end
end
