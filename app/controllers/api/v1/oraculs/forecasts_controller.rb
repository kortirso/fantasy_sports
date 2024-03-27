# frozen_string_literal: true

module Api
  module V1
    module Oraculs
      class ForecastsController < Api::V1Controller
        include Deps[update_form: 'forms.oraculs.forecasts.update']

        before_action :find_oraculs_forecast, only: %i[update]

        def update
          # commento: oraculs_forecasts.value
          case update_form.call(user: Current.user, forecast: @oraculs_forecast, params: oraculs_forecast_params)
          in { errors: errors } then render json: { errors: errors }, status: :unprocessable_entity
          else render json: { result: 'ok' }, status: :ok
          end
        end

        private

        def find_oraculs_forecast
          @oraculs_forecast = ::Oraculs::Forecast.find(params[:id])
        end

        def oraculs_forecast_params
          params.require(:oraculs_forecast).permit(value: [])
        end
      end
    end
  end
end
