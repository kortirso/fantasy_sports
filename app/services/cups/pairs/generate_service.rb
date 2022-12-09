# frozen_string_literal: true

module Cups
  module Pairs
    class GenerateService
      prepend ApplicationService

      def call(week:)
        @week = week
        week.season.all_fantasy_leagues.general.each do |fantasy_league|
          next unless fantasy_league.cup

          cups_round = fantasy_league.cup.cups_rounds.find_by(week: week)
          next unless cups_round

          @fantasy_league = fantasy_league
          @cups_round = cups_round
          previous_cups_round = @fantasy_league.cup.cups_rounds.find_by(position: @cups_round.position + 1)
          create_pairs(lineup_ids(previous_cups_round))
        end
      end

      private

      def lineup_ids(previous_cups_round)
        fantasy_teams = previous_cups_round.nil? ? best_fantasy_teams : previous_round_winners(previous_cups_round)
        best_lineups(fantasy_teams)
      end

      # Initial cup round, selecting from best fantasy teams
      def best_lineups(fantasy_teams)
        Lineup
          .where(fantasy_team: fantasy_teams, week: @week)
          .joins(:fantasy_team)
          .order('fantasy_teams.points DESC')
          .pluck(:id)
      end

      # Need to select winners from pairs from previous round
      def previous_round_winners(previous_cups_round)
        previous_cups_round
          .cups_pairs
          .includes(home_lineup: :fantasy_team, visitor_lineup: :fantasy_team)
          .map { |pair| select_better_lineup(pair) }
      end

      def select_better_lineup(pair)
        points_difference = fetch_points_difference(pair)
        home_fantasy_team = pair.home_lineup.fantasy_team
        visitor_fantasy_team = pair.visitor_lineup.fantasy_team
        return home_fantasy_team if points_difference.positive?
        return visitor_fantasy_team if points_difference.negative?

        # TODO: need better algorithm for selecting pair winner
        # Current approach - team with better points go further
        team_points_difference = home_fantasy_team.points - visitor_fantasy_team.points
        team_points_difference.negative? ? visitor_fantasy_team : home_fantasy_team
      end

      def fetch_points_difference(pair)
        home_result = pair.home_lineup.points + pair.home_lineup.penalty_points
        visitor_result = pair.visitor_lineup.points + pair.visitor_lineup.penalty_points

        home_result - visitor_result
      end

      def best_fantasy_teams
        @best_fantasy_teams ||=
          @fantasy_league
          .fantasy_teams
          .order(points: :desc)
          .first(Cups::CreateService::ROUND_VALUES[@cups_round.position][:teams_amount])
      end

      def create_pairs(lineup_ids)
        pairs = []

        loop do
          home_lineup_id = lineup_ids.shift
          visitor_lineup_id = lineup_ids.pop
          break if home_lineup_id.nil? && visitor_lineup_id.nil?

          pairs.push({
            cups_round_id: @cups_round.id,
            home_lineup_id: home_lineup_id,
            visitor_lineup_id: visitor_lineup_id
          })
        end

        Cups::Pair.upsert_all(pairs) if pairs.any?
      end
    end
  end
end
