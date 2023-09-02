# frozen_string_literal: true

module Games
  module Players
    module Points
      module Calculate
        class BasketballService < Games::Players::Points::CalculateService
          private

          def methods_for_stats
            {
              'P' => :field_goals_points,
              'REB' => :rebounds_points,
              'A' => :assists_points,
              'BLK' => :blocks_points,
              'STL' => :steals_points,
              'TO' => :turnovers_points
            }
          end

          def field_goals_points(value)
            value
          end

          def rebounds_points(value)
            value * 1.2
          end

          def assists_points(value)
            value * 1.5
          end

          def blocks_points(value)
            value * 3
          end

          def steals_points(value)
            value * 3
          end

          def turnovers_points(value)
            value * -1.5
          end
        end
      end
    end
  end
end
