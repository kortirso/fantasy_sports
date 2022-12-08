# frozen_string_literal: true

module Cups
  class Pair < ApplicationRecord
    self.table_name = :cups_pairs

    belongs_to :cups_round, class_name: '::Cups::Round', foreign_key: :cups_round_id
    belongs_to :home_lineup, class_name: '::Lineup', foreign_key: :home_lineup_id
    belongs_to :visitor_lineup, class_name: '::Lineup', foreign_key: :visitor_lineup_id
  end
end
