# frozen_string_literal: true

module Lineups
  module Players
    # Service for generating lineup players with all properties from teams players of fantasy team
    # This service usually run only for first week
    class CreateService
      prepend ApplicationService

      def call(lineup:)
        prepare_data
        @lineup = lineup

        select_captains if Sports.sport(sport_kind)['captain']
        Sports.positions_for_sport(sport_kind).each { |position_kind, values|
          collect_teams_players(teams_players_by_position[position_kind], values['default_amount'])
        }

        Lineups::Player.upsert_all(@teams_players)
      end

      private

      def prepare_data
        @teams_players = []
        @change_order  = 1
        @captains      = {}
      end

      def sport_kind
        @lineup.fantasy_team.sport_kind
      end

      def fantasy_team_players
        @fantasy_team_players ||= @lineup.fantasy_team.teams_players.active
      end

      def select_captains
        return if fantasy_team_players.size < 2

        best_players = fantasy_team_players.order(price_cents: :desc).first(2)
        @captains = {
          best_players[0].id => Lineups::Player::CAPTAIN,
          best_players[1].id => Lineups::Player::ASSISTANT
        }
      end

      def teams_players_by_position
        @teams_players_by_position ||= fantasy_team_players.includes(:player).group_by { |e| e.player.position_kind }
      end

      def collect_teams_players(teams_players, default_active_players)
        teams_players[0...default_active_players].each { |teams_player|
          @teams_players.push(active_teams_player_data(teams_player))
        }
        teams_players[default_active_players..].each { |teams_player|
          @teams_players.push(inactive_teams_player_data(teams_player))
          @change_order += 1
        }
      end

      def active_teams_player_data(teams_player)
        {
          teams_player_id: teams_player.id,
          lineup_id: @lineup.id,
          active: true,
          change_order: 0,
          status: @captains[teams_player.id] || Lineups::Player::REGULAR
        }
      end

      def inactive_teams_player_data(teams_player)
        {
          teams_player_id: teams_player.id,
          lineup_id: @lineup.id,
          active: false,
          change_order: @change_order,
          status: @captains[teams_player.id] || Lineups::Player::REGULAR
        }
      end
    end
  end
end
