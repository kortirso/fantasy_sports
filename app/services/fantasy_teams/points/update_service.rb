# frozen_string_literal: true

module FantasyTeams
  module Points
    class UpdateService
      prepend ApplicationService

      def call(fantasy_team_ids:)
        fantasy_teams =
          FantasyTeam
            .where(id: fantasy_team_ids)
            .includes(:lineups)
            .map do |fantasy_team|
              {
                id: fantasy_team.id,
                points: fantasy_team.lineups.pluck(:points, :penalty_points).flatten.sum,
                uuid: fantasy_team.uuid,
                user_id: fantasy_team.user_id,
                season_id: fantasy_team.season_id
              }
            end
        # commento: fantasy_teams.points
        FantasyTeam.upsert_all(fantasy_teams) if fantasy_teams.any?
      end
    end
  end
end
