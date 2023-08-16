# frozen_string_literal: true

module FantasyTeams
  class UpdatePointsService
    prepend ApplicationService

    def call(fantasy_team_ids:)
      FantasyTeam
        .where(id: fantasy_team_ids)
        .each { |fantasy_team|
          # commento: fantasy_teams.points
          fantasy_team.update(points: fantasy_team.lineups.pluck(:points, :penalty_points).flatten.sum)
        }
    end
  end
end
