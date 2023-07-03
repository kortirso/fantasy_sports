# frozen_string_literal: true

module FantasyTeams
  module Lineups
    class GenerateSampleService
      prepend ApplicationService

      BUDGET_CENTS = 10_000
      EXPENSIVE_PRICE_KOEFFICIENT = 1.2

      attr_reader :budget_cents

      def call(season:)
        @season = season

        initialize_static_data
        find_teams_players_ids
      end

      private

      def initialize_static_data
        @sport = Sports.sport(@season.league.sport_kind)

        @price_cents_per_player = EXPENSIVE_PRICE_KOEFFICIENT * BUDGET_CENTS / @sport['max_players']
        @sport_positions = Sports.positions_for_sport(@season.league.sport_kind)
      end

      def find_teams_players_ids
        initialize_variables

        grouped_teams_players.each_value do |teams_players|
          teams_players.shuffle.each do |teams_player|
            position_kind = teams_player.player.position_kind
            seasons_team_id = teams_player.seasons_team_id

            next if position_is_full?(position_kind)
            next if maximum_player_from_team?(seasons_team_id)

            update_variables(position_kind, seasons_team_id, teams_player)
          end
        end

        find_teams_players_ids if result_invalid?
      end

      def initialize_variables
        @result = []
        @selected_teams = []
        @selected_positions = []
        @budget_cents = BUDGET_CENTS
      end

      def grouped_teams_players
        @season
          .active_teams_players
          .where('price_cents <= ?', @price_cents_per_player)
          .includes(:player)
          .group_by(&:seasons_team_id)
          .sort_by { rand }
          .to_h
      end

      def position_is_full?(position_kind)
        @selected_positions.count { |e| e == position_kind } == @sport_positions[position_kind]['total_amount']
      end

      def maximum_player_from_team?(seasons_team_id)
        @selected_teams.count { |e| e == seasons_team_id } == @sport['max_team_players']
      end

      def update_variables(position_kind, seasons_team_id, teams_player)
        @selected_positions.push(position_kind)
        @selected_teams.push(seasons_team_id)
        @result.push(teams_player.id)
        @budget_cents -= teams_player.price_cents
      end

      def result_invalid?
        @budget_cents.negative? || @result.size != @sport['max_players']
      end
    end
  end
end
