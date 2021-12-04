# frozen_string_literal: true

module Lineups
  module Players
    module Create
      class FootballService
        prepend ApplicationService

        def call(lineup:)
          prepare_data
          @lineup = lineup

          Sports.positions_for_sport('football').each { |position_kind, values|
            collect_teams_players(teams_players_by_position[position_kind], values['default_amount'])
          }

          Lineups::Player.upsert_all(@teams_players)
        end

        private

        def prepare_data
          @teams_players = []
          @change_order  = 1
        end

        def teams_players_by_position
          @teams_players_by_position ||=
            @lineup.fantasy_team.teams_players.active.includes(:player).group_by { |e|
              e.player.position_kind
            }
        end

        def collect_teams_players(teams_players, default_active_players)
          teams_players[0...default_active_players].each { |teams_player|
            @teams_players.push(active_teams_player_data(teams_player))
          }
          teams_players[default_active_players..-1].each { |teams_player|
            @teams_players.push(inactive_teams_player_data(teams_player))
            @change_order += 1
          }
        end

        def active_teams_player_data(teams_player)
          {
            teams_player_id: teams_player.id,
            lineup_id:       @lineup.id,
            active:          true,
            change_order:    0
          }
        end

        def inactive_teams_player_data(teams_player)
          {
            teams_player_id: teams_player.id,
            lineup_id:       @lineup.id,
            active:          false,
            change_order:    @change_order
          }
        end
      end
    end
  end
end
