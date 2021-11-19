# frozen_string_literal: true

module Views
  module Homes
    module Show
      class FantasyTeamLinkComponent < ViewComponent::Base
        def initialize(league:, user:)
          @league       = league
          @fantasy_team = @league.active_season.fantasy_teams.find_by(user: user)

          super()
        end
      end
    end
  end
end
