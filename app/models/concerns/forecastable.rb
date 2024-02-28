# frozen_string_literal: true

module Forecastable
  extend ActiveSupport::Concern

  included do
    has_many :oraculs_forecasts,
             class_name: '::Oraculs::Forecast',
             as: :forecastable,
             dependent: :destroy
  end

  def predictable?
    start_at && DateTime.now < start_at - 2.hours
  end
end
