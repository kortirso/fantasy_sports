# frozen_string_literal: true

module Games
  module Players
    module Points
      class CalculateService
        prepend ApplicationService

        def initialize(
          football_service:   Games::Players::Points::Calculate::FootballService,
          basketball_service: Games::Players::Points::Calculate::BasketballService
        )
          @football_service = football_service
          @basketball_service = basketball_service
        end

        def call(position_kind:, statistic:)
          @result =
            service_for_call(Sports.position(position_kind)['sport_kind'])
            .call(position_kind: position_kind, statistic: statistic)
            .result
        end

        private

        def service_for_call(sport_kind)
          case sport_kind
          when Sportable::FOOTBALL then @football_service
          when Sportable::BASKETBALL then @basketball_service
          end
        end
      end
    end
  end
end
