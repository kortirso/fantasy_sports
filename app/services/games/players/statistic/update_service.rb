# frozen_string_literal: true

module Games
  module Players
    module Statistic
      class UpdateService
        prepend ApplicationService

        def initialize(
          points_calculate_service: Games::Players::Points::CalculateService
        )
          @points_calculate_service = points_calculate_service
        end

        def call(games_player:, statistic: {})
          @result =
            @points_calculate_service.call(position_kind: games_player.position_kind, statistic: statistic).result

          games_player.update(points: @result, statistic: statistic)
        end
      end
    end
  end
end
