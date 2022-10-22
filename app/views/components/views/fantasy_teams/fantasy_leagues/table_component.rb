# frozen_string_literal: true

module Views
  module FantasyTeams
    module FantasyLeagues
      class TableComponent < ApplicationViewComponent
        def initialize(fantasy_team:, fantasy_leagues:)
          @fantasy_team = fantasy_team
          @fantasy_leagues = fantasy_leagues

          super()
        end
      end
    end
  end
end
