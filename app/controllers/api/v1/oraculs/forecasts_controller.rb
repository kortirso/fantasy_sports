# frozen_string_literal: true

module Api
  module V1
    module Oraculs
      class ForecastsController < Api::V1Controller
        include Deps[update_form: 'forms.oraculs.forecasts.update']

        before_action :find_oraculs_forecast, only: %i[update]

        def update
          # commento: oraculs_forecasts.value
          update_form.call(user: Current.user, forecast: @oraculs_forecast, params: oraculs_forecast_params)
          render json: { result: 'ok' }, status: :ok
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
