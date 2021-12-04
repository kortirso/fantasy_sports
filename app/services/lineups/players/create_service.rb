# frozen_string_literal: true

module Lineups
  module Players
    class CreateService
      prepend ApplicationService

      def initialize(
        create_football_players_service: Lineups::Players::Create::FootballService
      )
        @create_football_players_service = create_football_players_service
      end

      def call(lineup:)
        service_for_call(lineup).call(lineup: lineup)
      end

      private

      def service_for_call(lineup)
        case lineup.fantasy_team.sport_kind
        when Sportable::FOOTBALL then @create_football_players_service
        end
      end
    end
  end
end
