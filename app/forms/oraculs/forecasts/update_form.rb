# frozen_string_literal: true

module Oraculs
  module Forecasts
    class UpdateForm
      def call(user:, forecast:, params:)
        if forecast.oraculs_lineup.oracul.user_id != user.id
          return { errors: [I18n.t('forms.oraculs.forecasts.update.invalid')] }
        end
        unless forecast.forecastable.predictable?
          return { errors: [I18n.t('forms.oraculs.forecasts.update.not_predictable')] }
        end

        error = validate_forecastable(forecast.forecastable, params)
        return { errors: [error] } if error

        forecast.update!(params)

        { result: forecast.reload }
      end

      private

      def validate_forecastable(forecastable, params)
        return if forecastable.is_a?(Game)
        return if forecastable.elimination_kind == Cups::Pair::SINGLE

        required_wins = forecastable.required_wins
        value = params[:value].map(&:to_i)
        return if value.one?(required_wins) && value.one? { |point| point < required_wins }

        I18n.t('forms.oraculs.forecasts.update.required_wins', count: required_wins)
      end
    end
  end
end
