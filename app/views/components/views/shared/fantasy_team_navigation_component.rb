# frozen_string_literal: true

module Views
  module Shared
    class FantasyTeamNavigationComponent < ApplicationViewComponent
      def initialize(fantasy_team: nil)
        @fantasy_team = fantasy_team

        super()
      end
    end
  end
end