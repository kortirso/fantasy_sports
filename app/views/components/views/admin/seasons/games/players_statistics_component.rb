# frozen_string_literal: true

module Views
  module Admin
    module Seasons
      module Games
        class PlayersStatisticsComponent < ApplicationViewComponent
          def initialize(index:, form:, season_team:, games_players:, statistic:)
            @index = index
            @form = form
            @season_team = season_team
            @games_players = games_players
            @statistic = statistic

            super()
          end
        end
      end
    end
  end
end
