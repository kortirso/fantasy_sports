# frozen_string_literal: true

module Achievements
  module Lineups
    class PointsJob < ApplicationJob
      queue_as :default

      def perform
        Lineup
          .includes(fantasy_team: :user)
          .where(fantasy_teams: { sport_kind: [Sportable::BASKETBALL, Sportable::FOOTBALL] })
          .find_each { |lineup| award_lineup(lineup) }
      end

      private

      def award_lineup(lineup)
        case lineup.fantasy_team.sport_kind
        when Sportable::BASKETBALL
          Achievement.award(:basketball_lineup_points, lineup.points, lineup.fantasy_team.user)
        when Sportable::FOOTBALL
          Achievement.award(:football_lineup_points, lineup.points, lineup.fantasy_team.user)
        end
      end
    end
  end
end
