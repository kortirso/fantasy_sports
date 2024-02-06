# frozen_string_literal: true

module Views
  module Homes
    module Show
      class FantasyTeamLinkComponent < ApplicationViewComponent
        def initialize(season:, fantasy_team: nil, lineup: nil, deadline: nil, overall_league: nil)
          @season = season
          @fantasy_team = fantasy_team
          @lineup = lineup
          @deadline = deadline
          @overall_league = overall_league

          super()
        end
      end
    end
  end
end
