# frozen_string_literal: true

module Lineups
  module Points
    class UpdateService
      prepend ApplicationService

      def initialize(
        fantasy_teams_update_points_service: FantasyTeams::Points::UpdateService
      )
        @fantasy_teams_update_points_service = fantasy_teams_update_points_service
      end

      def call(lineup_ids:)
        fantasy_team_ids = []
        lineups = Lineup.where(id: lineup_ids).map do |lineup|
          fantasy_team_ids.push(lineup.fantasy_team_id)

          {
            id: lineup.id,
            points: players(lineup).pluck(:points).sum(&:to_d),
            fantasy_team_id: lineup.fantasy_team_id,
            week_id: lineup.week_id
          }
        end
        # commento: lineups.points
        Lineup.upsert_all(lineups) if lineups.any?

        @fantasy_teams_update_points_service.call(fantasy_team_ids: fantasy_team_ids)
      end

      private

      def players(lineup)
        # eager load does not help while using .active scope
        lineup.active_chips&.include?(Chipable::BENCH_BOOST) ? lineup.lineups_players : lineup.lineups_players.active
      end
    end
  end
end
