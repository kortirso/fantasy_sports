# frozen_string_literal: true

module Views
  module Shared
    class StatisticComponent < ApplicationViewComponent
      def initialize(fantasy_team:, week: nil, score_detect_service: ::Cups::Pairs::ScoreDetectService)
        @fantasy_team = fantasy_team
        @week = week
        @season = fantasy_team.season
        @score_detect_service = score_detect_service

        super()
      end

      def overall_points
        @overall_points ||= @fantasy_team.points
      end

      def overall_rank
        @season.fantasy_teams.completed.where('points > ?', overall_points).size + 1
      end

      def fantasy_teams_amount
        @season.fantasy_teams.completed.size
      end

      def fantasy_leagues
        @fantasy_team.fantasy_leagues.order(global: :desc).map do |fantasy_league|
          {
            uuid: fantasy_league.uuid,
            name: fantasy_league.name,
            place: fantasy_league.members.where('points > ?', @fantasy_team.points).size + 1
          }
        end
      end

      def lineups_fantasy_leagues
        lineup = @fantasy_team.lineups.find_by(week_id: @week&.id)
        return [] unless lineup

        lineup.fantasy_leagues.order(global: :desc).map do |fantasy_league|
          {
            uuid: fantasy_league.uuid,
            name: fantasy_league.name,
            place: fantasy_league.members.where('points > ?', lineup.points).size + 1
          }
        end
      end

      def fantasy_cups
        @fantasy_cups ||=
          Cup.where(fantasy_league: @fantasy_team.fantasy_leagues).map do |cup|
            pairs = cup.cups_pairs.joins(:home_lineup, :visitor_lineup)
            pair =
              pairs
              .where(home_lineup: { fantasy_team_id: @fantasy_team })
              .or(
                pairs.where(visitor_lineup: { fantasy_team_id: @fantasy_team })
              ).order(id: :asc).last

            {
              uuid: cup.uuid,
              name: cup.name,
              game_week: pair ? "GW #{pair.cups_round.week.position}" : '',
              pair_result: pair_result(pair)
            }
          end
      end

      def pair_result(pair)
        return '' unless pair

        @score_detect_service.call(cups_pair: pair, fantasy_team: @fantasy_team).result.join(' - ')
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
