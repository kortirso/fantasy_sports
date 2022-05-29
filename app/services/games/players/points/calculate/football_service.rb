# frozen_string_literal: true

module Games
  module Players
    module Points
      module Calculate
        class FootballService
          prepend ApplicationService

          METHODS_FOR_STATS = {
            'MP' => 'minutes_played_points',
            'GS' => 'goals_scored_points',
            'A'  => 'assists_points',
            'CS' => 'clean_sheets_points',
            'GC' => 'goals_conceded_points',
            'OG' => 'own_goals_points',
            'PS' => 'penalties_saved_points',
            'PM' => 'penalties_missed_points',
            'YC' => 'yellow_cards_points',
            'RC' => 'red_cards_points',
            'S'  => 'saves_points',
            'B'  => 'bonus_points'
          }.freeze

          def call(statistic:, position_kind:)
            @position_kind = position_kind
            @result = statistic.inject(0) do |acc, (param, value)|
              method_name = METHODS_FOR_STATS[param]
              next acc unless method_name

              acc + send(method_name, value.to_i)
            end
          end

          private

          def minutes_played_points(value)
            return 2 if value >= 60

            1
          end

          def goals_scored_points(value)
            case @position_kind
            when Positionable::GOALKEEPER, Positionable::DEFENDER then value * 6
            when Positionable::MIDFIELDER then value * 5
            else value * 4
            end
          end

          def assists_points(value)
            value * 3
          end

          def clean_sheets_points(value)
            return 0 if value.zero?

            case @position_kind
            when Positionable::GOALKEEPER, Positionable::DEFENDER then 4
            when Positionable::MIDFIELDER then 1
            else 0
            end
          end

          def goals_conceded_points(value)
            case @position_kind
            when Positionable::GOALKEEPER, Positionable::DEFENDER then (value / 2) * -1
            else 0
            end
          end

          def own_goals_points(value)
            value * -2
          end

          def penalties_saved_points(value)
            return 0 unless @position_kind == Positionable::GOALKEEPER

            value * 5
          end

          def penalties_missed_points(value)
            value * -2
          end

          def yellow_cards_points(value)
            value * -1
          end

          def red_cards_points(value)
            value * -3
          end

          def saves_points(value)
            return 0 unless @position_kind == Positionable::GOALKEEPER

            value / 3
          end

          def bonus_points(value)
            value
          end
        end
      end
    end
  end
end
