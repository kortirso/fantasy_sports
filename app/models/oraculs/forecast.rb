# frozen_string_literal: true

module Oraculs
  class Forecast < ApplicationRecord
    self.table_name = :oraculs_forecasts

    include Uuidable

    belongs_to :oraculs_lineup, class_name: '::Oraculs::Lineup', foreign_key: :oraculs_lineup_id
    belongs_to :forecastable, polymorphic: true # Game/Cups::Pair
  end
end
