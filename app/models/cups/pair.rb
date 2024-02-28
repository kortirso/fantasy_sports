# frozen_string_literal: true

module Cups
  class Pair < ApplicationRecord
    self.table_name = :cups_pairs

    include Forecastable

    belongs_to :cups_round, class_name: '::Cups::Round', foreign_key: :cups_round_id
  end
end
