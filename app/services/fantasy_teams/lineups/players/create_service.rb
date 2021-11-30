# frozen_string_literal: true

module FantasyTeams
  module Lineups
    module Players
      class CreateService
        prepend ApplicationService

        def initialize(
          create_football_service: FantasyTeams::Lineups::Players::Create::FootballService
        )
          @create_football_service = create_football_service
        end

        def call(lineup:)
          service_for_call(lineup).call(lineup: lineup)
        end

        private

        def service_for_call(lineup)
          case lineup.week.leagues_season.league.sport.kind
          when Sport::FOOTBALL then @create_football_service
          end
        end
      end
    end
  end
end
