# frozen_string_literal: true

module Lineups
  module Players
    class UpdateService
      prepend ApplicationService

      def initialize(
        update_football_players_service: Lineups::Players::Update::FootballService
      )
        @update_football_players_service = update_football_players_service
      end

      def call(lineup:, lineup_players_params:)
        service_for_call(lineup).call(lineup: lineup, lineup_players_params: lineup_players_params)
      end

      private

      def service_for_call(lineup)
        case lineup.week.season.league.sport.kind
        when Sport::FOOTBALL then @update_football_players_service
        end
      end
    end
  end
end
