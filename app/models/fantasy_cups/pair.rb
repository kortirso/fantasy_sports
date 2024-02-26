# frozen_string_literal: true

module FantasyCups
  class Pair < ApplicationRecord
    self.table_name = :fantasy_cups_pairs

    belongs_to :fantasy_cups_round, class_name: '::FantasyCups::Round', foreign_key: :cups_round_id
    belongs_to :home_lineup, class_name: '::Lineup', foreign_key: :home_lineup_id, optional: true
    belongs_to :visitor_lineup, class_name: '::Lineup', foreign_key: :visitor_lineup_id, optional: true
  end
end
