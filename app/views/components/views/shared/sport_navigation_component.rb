# frozen_string_literal: true

module Views
  module Shared
    class SportNavigationComponent < ApplicationViewComponent
      def initialize(fantasy_team: nil)
        @fantasy_team = fantasy_team
        @unread_achievements_count = Current.user.kudos_users_achievements.unread.count

        super()
      end
    end
  end
end
