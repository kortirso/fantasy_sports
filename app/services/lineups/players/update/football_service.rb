# frozen_string_literal: true

module Lineups
  module Players
    module Update
      class FootballService
        prepend ApplicationService

        def initialize(
          players_validator: Lineups::PlayersValidator
        )
          @players_validator = players_validator.new(sport_kind: Sportable::FOOTBALL)
        end

        def call(lineup:, lineups_players_params:)
          return if validate_params(lineup, lineups_players_params) && failure?

          update_lineups_players(lineup, lineups_players_params)
        end

        private

        def validate_params(lineup, lineups_players_params)
          fails!(@players_validator.call(lineup: lineup, lineups_players_params: lineups_players_params))
        end

        def update_lineups_players(lineup, lineups_players_params)
          grouped_params = lineups_players_params.index_by { |players_param| players_param['id'] }
          lineup.lineups_players.includes(:lineup, :teams_player).each do |lineups_player|
            lineups_player.update(grouped_params[lineups_player.id].except(:id))
          end
        end
      end
    end
  end
end
