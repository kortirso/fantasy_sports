# frozen_string_literal: true

module Api
  module Frontend
    module Oraculs
      class ForecastsController < ApplicationController
        include Deps[update_form: 'forms.oraculs.forecasts.update']

        before_action :find_oraculs_lineup, only: %i[index]
        before_action :find_oraculs_forecast, only: %i[update]

        def index
          render json: { forecasts: forecasts }, status: :ok
        end

        def update
          # commento: oraculs_forecasts.value
          update_form.call(user: Current.user, forecast: @oraculs_forecast, params: oraculs_forecast_params)
          render json: { result: 'ok' }, status: :ok
        end

        private

        def forecasts
          owner = @oraculs_lineup.oracul.user_id == Current.user.id
          Rails.cache.fetch(
            [
              'api_frontend_oraculs_forecasts_index_v1',
              @oraculs_lineup.id,
              @oraculs_lineup.updated_at,
              owner
            ],
            expires_in: 12.hours,
            race_condition_ttl: 10.seconds
          ) do
            ::Oraculs::ForecastSerializer.new(
              @oraculs_lineup.oraculs_forecasts,
              params: {
                owner: owner,
                forecastables: forecastables
              }
            ).serializable_hash
          end
        end

        def find_oraculs_lineup
          @oraculs_lineup = ::Oraculs::Lineup.find_by!(uuid: params[:oraculs_lineup_id])
        end

        def find_oraculs_forecast
          @oraculs_forecast = ::Oraculs::Forecast.find_by!(uuid: params[:id])
        end

        def forecastables
          @oraculs_lineup.week? ? @oraculs_lineup.periodable.games.to_a : @oraculs_lineup.periodable.cups_pairs.to_a
        end

        def oraculs_forecast_params
          params.require(:oraculs_forecast).permit(value: [])
        end
      end
    end
  end
end
