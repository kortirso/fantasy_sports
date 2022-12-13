# frozen_string_literal: true

module Cups
  module Pairs
    class WinnerDetectService
      prepend ApplicationService

      def call(cups_pair:)
        @cups_pair = cups_pair
        @result = select_winner_fantasy_team
      end

      private

      def select_winner_fantasy_team
        points_difference = fetch_points_difference
        home_fantasy_team = @cups_pair.home_lineup.fantasy_team
        visitor_fantasy_team = @cups_pair.visitor_lineup.fantasy_team
        return home_fantasy_team if points_difference.positive?
        return visitor_fantasy_team if points_difference.negative?

        detect_winner_by_players
      end

      def detect_winner_by_players
        "Cups::Pairs::WinnerDetect::For#{@cups_pair.home_lineup.fantasy_team.sport_kind.capitalize}Service"
          .constantize
          .call(home_lineup: @cups_pair.home_lineup, visitor_lineup: @cups_pair.visitor_lineup)
          .result
      end

      def fetch_points_difference
        home_team_score - visitor_team_score
      end

      def home_team_score
        @cups_pair.home_lineup.points.to_d + @cups_pair.home_lineup.penalty_points.to_d
      end

      def visitor_team_score
        @cups_pair.visitor_lineup.points.to_d + @cups_pair.visitor_lineup.penalty_points.to_d
      end
    end
  end
end
