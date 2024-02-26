# frozen_string_literal: true

module FantasyCups
  module Pairs
    class ScoreDetectService
      prepend ApplicationService

      def call(cups_pair:, fantasy_team:)
        @cups_pair = cups_pair
        @fantasy_team = fantasy_team
        @result = score_for_team
      end

      private

      def score_for_team
        result = [home_team_score, visitor_team_score]
        @fantasy_team == @cups_pair.visitor_lineup.fantasy_team ? result.reverse : result
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
