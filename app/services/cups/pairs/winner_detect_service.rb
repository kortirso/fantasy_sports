# frozen_string_literal: true

module Cups
  module Pairs
    class WinnerDetectService
      prepend ApplicationService

      def call(cups_pair:, format:)
        @cups_pair = cups_pair

        @result =
          case format
          when :winner_team then select_winner_fantasy_team
          when :game_score then game_score
          end
      end

      private

      def select_winner_fantasy_team
        points_difference = fetch_points_difference
        home_fantasy_team = @cups_pair.home_lineup.fantasy_team
        visitor_fantasy_team = @cups_pair.visitor_lineup.fantasy_team
        return home_fantasy_team if points_difference.positive?
        return visitor_fantasy_team if points_difference.negative?

        # TODO: need better algorithm for selecting pair winner
        # Current approach - team with better points go further
        team_points_difference = home_fantasy_team.points - visitor_fantasy_team.points
        team_points_difference.negative? ? visitor_fantasy_team : home_fantasy_team
      end

      def game_score
        [home_team_score, visitor_team_score]
      end

      def home_team_score
        @cups_pair.home_lineup.points + @cups_pair.home_lineup.penalty_points
      end

      def visitor_team_score
        @cups_pair.visitor_lineup.points + @cups_pair.visitor_lineup.penalty_points
      end

      def fetch_points_difference
        home_team_score - visitor_team_score
      end
    end
  end
end
