# frozen_string_literal: true

module Oraculs
  module Lineups
    module Points
      class UpdateService
        include Deps[oraculs_update_points: 'services.oraculs.points.update']

        # rubocop: disable Metrics/AbcSize
        def call(week_id:)
          oracul_ids = []
          games = games(week_id)
          grouped_forecasts = forecasts(games.pluck(:id))

          lineups = oraculs_lineups(week_id).map do |lineup|
            oracul_ids << lineup[:oracul_id]
            lineup.merge(
              points: games.each_with_index.inject(0) { |acc, (game, index)|
                acc + find_points(game, grouped_forecasts[lineup[:id]][index])
              }
            )
          end
          # commento: oraculs_lineups.points
          Oraculs::Lineup.upsert_all(lineups) if lineups.any?

          oraculs_update_points.call(oracul_ids: oracul_ids)
        end
        # rubocop: enable Metrics/AbcSize

        private

        def oraculs_lineups(week_id)
          Oraculs::Lineup
            .where(periodable_id: week_id, periodable_type: 'Week')
            .hashable_pluck(:id, :uuid, :oracul_id, :periodable_id, :periodable_type)
        end

        def games(week_id)
          Game
            .where(week_id: week_id)
            .where.not(points: [])
            .order(id: :asc)
            .hashable_pluck(:id, :points)
        end

        def forecasts(game_ids)
          Oraculs::Forecast
            .where(forecastable_id: game_ids, forecastable_type: 'Game')
            .order(forecastable_id: :asc)
            .hashable_pluck(:oraculs_lineup_id, :forecastable_id, :value)
            .group_by { |element| element[:oraculs_lineup_id] }
        end

        # rubocop: disable Metrics/AbcSize
        def find_points(game, forecast)
          return 0 if forecast[:value].empty?

          game_home_score = game[:points][0]
          forecast_home_score = forecast[:value][0]

          game_difference = game[:points][0] - game[:points][1]
          forecast_difference = forecast[:value][0] - forecast[:value][1]

          return 3 if game_home_score == forecast_home_score && game_difference == forecast_difference
          return 2 if game_difference == forecast_difference
          return 1 if difference_result(game[:points]) == difference_result(forecast[:value])

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
