# frozen_string_literal: true

FactoryBot.define do
  factory :oraculs_forecast, class: 'Oraculs::Forecast' do
    oraculs_lineup
    forecastable factory: %i[game]
  end
end
