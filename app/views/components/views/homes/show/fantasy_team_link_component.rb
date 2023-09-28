# frozen_string_literal: true

module Views
  module Homes
    module Show
      class FantasyTeamLinkComponent < ApplicationViewComponent
        def initialize(season_uuid:, fantasy_team: nil)
          @season_uuid = season_uuid
          @fantasy_team = fantasy_team

          super()
        end
      end
    end
  end
end
