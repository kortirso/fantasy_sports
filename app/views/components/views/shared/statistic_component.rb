# frozen_string_literal: true

module Views
  module Shared
    class StatisticComponent < ApplicationViewComponent
      def initialize(fantasy_team:, season:, winner_detect_service: ::Cups::Pairs::WinnerDetectService)
        @fantasy_team = fantasy_team
        @season = season
        @winner_detect_service = winner_detect_service

        super()
      end

      def overall_points
        @overall_points ||= @fantasy_team.points
      end

      def overall_rank
        @season.fantasy_teams.where('points > ?', overall_points).size + 1
      end

      def fantasy_teams_amount
        @season.fantasy_teams.size
      end

      def fantasy_leagues
        @fantasy_team.fantasy_leagues.order(global: :desc).map do |fantasy_league|
          {
            uuid: fantasy_league.uuid,
            name: fantasy_league.name,
            place: fantasy_league.fantasy_teams.where('points > ?', @fantasy_team.points).size + 1
          }
        end
      end

      def fantasy_cups
        Cup.where(fantasy_league: @fantasy_team.fantasy_leagues).map do |cup|
          pairs = cup.cups_pairs.joins(:home_lineup, :visitor_lineup)
          pair =
            pairs
            .where(home_lineup: { fantasy_team_id: @fantasy_team })
            .or(
              pairs.where(visitor_lineup: { fantasy_team_id: @fantasy_team })
            ).order(id: :asc).last

          {
            name: cup.name,
            pair: pair,
            pair_result: pair_result(pair)
          }
        end
      end

      def pair_result(pair)
        return '' unless pair

        @winner_detect_service.call(cups_pair: pair).result == @fantasy_team ? 'W' : 'L'
      end

      def squad_value
        @fantasy_team.teams_players.sum(:price_cents) / 100.0
      end

      def squad_budget
        @fantasy_team.budget_cents / 100.0
      end
    end
  end
end
