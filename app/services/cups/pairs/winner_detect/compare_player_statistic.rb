# frozen_string_literal: true

module Cups
  module Pairs
    module WinnerDetect
      module ComparePlayerStatistic
        private

        # comparing sum of player stats, default - higher is better
        # for order == :lower - lower is better
        def compare_player_statistic(stat, order=:higher)
          return if @result

          home_result = statistic_result(home_players_statistic, stat, order)
          visitor_result = statistic_result(visitor_players_statistic, stat, order)
          return if home_result == visitor_result

          @result = home_result > visitor_result ? @home_lineup.fantasy_team : @visitor_lineup.fantasy_team
        end

        # last check, if fantasy team has more or equal points - it wins
        def better_fantasy_team
          return if @result

          team_points_difference = home_fantasy_team.points - visitor_fantasy_team.points
          @result = team_points_difference.negative? ? visitor_fantasy_team : home_fantasy_team
        end

        def statistic_result(statistic, stat, order)
          statistic.sum { |e| e[stat].to_d } * (order == :lower ? -1 : 1)
        end

        def home_players_statistic
          @home_players_statistic ||= @home_lineup.lineups_players.pluck(:statistic)
        end

        def home_fantasy_team
          @home_lineup.fantasy_team
        end

        def visitor_players_statistic
          @visitor_players_statistic ||= @visitor_lineup.lineups_players.pluck(:statistic)
        end

        def visitor_fantasy_team
          @visitor_lineup.fantasy_team
        end
      end
    end
  end
end
