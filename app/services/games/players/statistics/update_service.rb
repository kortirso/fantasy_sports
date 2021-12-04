# frozen_string_literal: true

module Games
  module Players
    module Statistics
      class UpdateService
        prepend ApplicationService

        def initialize(
          points_calculate_service: Games::Players::Points::CalculateService
        )
          @points_calculate_service = points_calculate_service
        end

        def call(games_player:, statistics: {})
          calculate_call = @points_calculate_service.call(position_kind: games_player.position_kind, statistics: statistics)

          games_player.update(points: calculate_call.result, statistics: statistics)
        end
      end
    end
  end
end
