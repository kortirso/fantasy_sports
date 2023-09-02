# frozen_string_literal: true

module Games
  module Players
    module Points
      class CalculateService
        prepend ApplicationService

        def call(statistic:, position_kind: nil)
          @position_kind = position_kind
          @result = statistic.inject(0.0) do |acc, (param, value)|
            method_name = methods_for_stats[param]
            next acc unless method_name

            acc + send(method_name, value.to_i)
          end
        end

        private

        def methods_for_stats
          raise NotImplementedError
        end
      end
    end
  end
end
