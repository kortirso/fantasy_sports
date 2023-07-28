# frozen_string_literal: true

module Views
  module Homes
    module Show
      class FantasyTeamLinkComponent < ApplicationViewComponent
        def initialize(season:)
          @season       = season
          @fantasy_team = @season.fantasy_teams.find_by(user: Current.user)

          super()
        end
      end
    end
  end
end
