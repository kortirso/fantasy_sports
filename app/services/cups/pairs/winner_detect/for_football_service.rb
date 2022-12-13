# frozen_string_literal: true

module Cups
  module Pairs
    module WinnerDetect
      class ForFootballService
        prepend ApplicationService
        include ComparePlayerStatistic

        def call(home_lineup:, visitor_lineup:)
          @home_lineup = home_lineup
          @visitor_lineup = visitor_lineup

          compare_player_statistic(Statable::GS)
          compare_player_statistic(Statable::GC, :lower)
          better_fantasy_team
        end
      end
    end
  end
end
