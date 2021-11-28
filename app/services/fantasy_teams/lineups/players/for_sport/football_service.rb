# frozen_string_literal: true

module FantasyTeams
  module Lineups
    module Players
      module ForSport
        class FootballService
          prepend ApplicationService

          def call(lineup:)
            prepare_data
            @lineup = lineup

            @sport.sports_positions.each { |sports_position|
              collect_teams_players(teams_players_by_position[sports_position.id], sports_position.default_amount)
            }

            FantasyTeams::Lineups::Player.upsert_all(@teams_players)
          end

          private

          def prepare_data
            @sport         = Sport.football.first
            @teams_players = []
            @change_order  = 1
          end

          def teams_players_by_position
            @teams_players_by_position ||=
              @lineup.fantasy_team.teams_players.active.includes(:player).group_by { |e|
                e.player.sports_position_id
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
              teams_player_id:         teams_player.id,
              fantasy_teams_lineup_id: @lineup.id,
              active:                  true,
              change_order:            0
            }
          end

          def inactive_teams_player_data(teams_player)
            {
              teams_player_id:         teams_player.id,
              fantasy_teams_lineup_id: @lineup.id,
              active:                  false,
              change_order:            @change_order
            }
          end
        end
      end
    end
  end
end
