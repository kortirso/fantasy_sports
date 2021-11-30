# frozen_string_literal: true

module FantasyTeams
  module Lineups
    module Players
      module Update
        class FootballService
          prepend ApplicationService

          def initialize(
            football_players_validator: ::Lineups::Players::ForSport::FootballValidator
          )
            @football_players_validator = football_players_validator
          end

          def call(lineup:, lineup_players_params:)
            validate_params(lineup, lineup_players_params)
            return if failure?

            update_lineups_players(lineup, lineup_players_params)
          end

          private

          def validate_params(lineup, lineup_players_params)
            fails!(@football_players_validator.call(lineup: lineup, lineup_players_params: lineup_players_params))
          end

          def update_lineups_players(lineup, lineup_players_params)
            grouped_params = lineup_players_params.index_by { |players_param| players_param['id'] }
            lineup.fantasy_teams_lineups_players.each do |lineups_player|
              lineups_player.update(grouped_params[lineups_player.id].except(:id))
            end
          end
        end
      end
    end
  end
end
