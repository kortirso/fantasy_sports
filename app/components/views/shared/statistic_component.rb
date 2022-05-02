# frozen_string_literal: true

module Views
  module Shared
    class StatisticComponent < ViewComponent::Base
      def initialize(fantasy_team:, season:)
        @fantasy_team = fantasy_team
        @season = season

        @overall_points = @fantasy_team.points
        @overall_rank = @season.fantasy_teams.where('points < ?', @overall_points).size + 1
        @fantasy_teams_amount = @season.fantasy_teams.size

        super()
      end
    end
  end
end
