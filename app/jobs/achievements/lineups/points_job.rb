# frozen_string_literal: true

module Achievements
  module Lineups
    class PointsJob < ApplicationJob
      queue_as :default

      def perform
        Lineup
          .includes(fantasy_team: :user)
          .where(fantasy_teams: { sport_kind: Sportable::BASKETBALL })
          .each do |lineup|
            Achievement.award(:basketball_lineup_points, lineup.points, lineup.fantasy_team.user)
          end
      end
    end
  end
end
