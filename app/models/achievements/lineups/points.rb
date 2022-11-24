# frozen_string_literal: true

module Achievements
  module Lineups
    class Points < Achievement
      rank 1, requirement: 25, points: 10
      rank 2, requirement: 50, points: 25
      rank 3, requirement: 100, points: 50

      # multirank achievement, need to check each level separately
      def self.award_for(lineup:)
        user = lineup.fantasy_team.user
        ranks.each do |rank|
          if !user.awarded?(achievement: self, rank: rank[:rank]) && lineup.points >= rank[:requirement]
            user.award(achievement: self, rank: rank[:rank], points: rank[:points])
          end
        end
      end
    end
  end
end
