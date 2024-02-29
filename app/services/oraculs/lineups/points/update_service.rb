# frozen_string_literal: true

module Oraculs
  module Lineups
    module Points
      class UpdateService
        include Deps[oraculs_update_points: 'services.oraculs.points.update']

        # rubocop: disable Metrics/AbcSize
        def call(periodable_id:, periodable_type:)
          oracul_ids = []
          forecastables = forecastables(periodable_id, periodable_type)
          grouped_forecasts = forecasts(forecastables.pluck(:id), periodable_type)

          lineups = oraculs_lineups(periodable_id, periodable_type).map do |lineup|
            oracul_ids << lineup[:oracul_id]
            lineup.merge(
              points: forecastables.each_with_index.inject(0) { |acc, (forecastable, index)|
                acc + find_points(forecastable, grouped_forecasts[lineup[:id]][index])
              }
            )
          end
          # commento: oraculs_lineups.points
          Oraculs::Lineup.upsert_all(lineups) if lineups.any?

          oraculs_update_points.call(oracul_ids: oracul_ids)
        end
        # rubocop: enable Metrics/AbcSize

        private

        def oraculs_lineups(periodable_id, periodable_type)
          Oraculs::Lineup
            .where(periodable_id: periodable_id, periodable_type: periodable_type)
            .hashable_pluck(:id, :uuid, :oracul_id, :periodable_id, :periodable_type)
        end

        def forecastables(periodable_id, periodable_type)
          games_relation(periodable_id, periodable_type)
            .where.not(points: [])
            .order(id: :asc)
            .hashable_pluck(:id, :points)
        end

        def games_relation(periodable_id, periodable_type)
          return Game.where(week_id: periodable_id) if periodable_type == 'Week'

          Cups::Pair.where(cups_round_id: periodable_id)
        end

        def forecasts(forecastable_ids, periodable_type)
          forecastable_type = periodable_type == 'Week' ? 'Game' : 'Cups::Pair'
          Oraculs::Forecast
            .where(forecastable_id: forecastable_ids, forecastable_type: forecastable_type)
            .order(forecastable_id: :asc)
            .hashable_pluck(:oraculs_lineup_id, :forecastable_id, :value)
            .group_by { |element| element[:oraculs_lineup_id] }
        end

        # rubocop: disable Metrics/AbcSize
        def find_points(forecastable, forecast)
          return 0 if forecast[:value].empty?

          game_home_score = forecastable[:points][0]
          forecast_home_score = forecast[:value][0]

          game_difference = forecastable[:points][0] - forecastable[:points][1]
          forecast_difference = forecast[:value][0] - forecast[:value][1]

          return 3 if game_home_score == forecast_home_score && game_difference == forecast_difference
          return 2 if game_difference == forecast_difference
          return 1 if difference_result(forecastable[:points]) == difference_result(forecast[:value])

          0
        end
        # rubocop: enable Metrics/AbcSize

        def difference_result(values)
          return 0 if values[0] == values[1]
          return 1 if values[0] > values[1]

          -1
        end
      end
    end
  end
end
