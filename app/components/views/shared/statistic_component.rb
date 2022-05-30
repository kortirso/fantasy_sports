# frozen_string_literal: true

module Views
  module Shared
    class StatisticComponent < ViewComponent::Base
      def initialize(fantasy_team:, season:)
        @fantasy_team = fantasy_team
        @season = season

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
        @fantasy_team.fantasy_leagues.order(global: :asc).map do |fantasy_league|
          {
            uuid:  fantasy_league.uuid,
            name:  fantasy_league.name,
            place: fantasy_league.fantasy_teams.where('points > ?', @fantasy_team.points).size + 1
          }
        end
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
