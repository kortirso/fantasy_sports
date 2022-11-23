# frozen_string_literal: true

module Achievements
  module FantasyTeams
    class Create < Achievement
      # one time achievement, no need to check levels
      def self.award_for(fantasy_team:)
        user = fantasy_team.user
        user.award(achievement: self, points: 5) unless user.awarded?(achievement: self)
      end
    end
  end
end
