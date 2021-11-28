# frozen_string_literal: true

module FantasyTeams
  module Lineups
    module Players
      class CreateForSportService
        prepend ApplicationService

        def initialize(
          football_service: FantasyTeams::Lineups::Players::ForSport::FootballService
        )
          @football_service = football_service
        end

        def call(lineup:)
          service_for_call(lineup).call(lineup: lineup)
        end

        private

        def service_for_call(lineup)
          case lineup.week.leagues_season.league.sport.kind
          when Sport::FOOTBALL then @football_service
          end
        end
      end
    end
  end
end
