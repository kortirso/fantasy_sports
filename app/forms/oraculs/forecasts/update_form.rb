# frozen_string_literal: true

module Oraculs
  module Forecasts
    class UpdateForm
      def call(user:, forecast:, params:)
        return { errors: ['Invalid forecast'] } if forecast.oraculs_lineup.oracul.user_id != user.id
        return { errors: ["Forecast can't be updated"] } unless forecast.forecastable.predictable?

        forecast.update!(params)

        { result: forecast.reload }
      end
    end
  end
end
