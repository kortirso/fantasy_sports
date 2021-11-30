# frozen_string_literal: true

module FantasyTeams
  module Lineups
    module Players
      class UpdateService
        prepend ApplicationService

        def initialize(
          update_football_service: FantasyTeams::Lineups::Players::Update::FootballService
        )
          @update_football_service = update_football_service
        end

        def call(lineup:, lineup_players_params:)
          service_for_call(lineup).call(lineup: lineup, lineup_players_params: lineup_players_params)
        end

        private

        def service_for_call(lineup)
          case lineup.week.leagues_season.league.sport.kind
          when Sport::FOOTBALL then @update_football_service
          end
        end
      end
    end
  end
end
