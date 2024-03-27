# frozen_string_literal: true

module Cups
  class Pair < ApplicationRecord
    self.table_name = :cups_pairs

    include Uuidable
    include Forecastable

    SINGLE = 'single'
    BEST_OF = 'best_of'

    belongs_to :cups_round, class_name: '::Cups::Round', foreign_key: :cups_round_id, touch: true

    enum elimination_kind: { SINGLE => 0, BEST_OF => 1 }
  end
end
