# frozen_string_literal: true

module FantasyCups
  class Round < ApplicationRecord
    self.table_name = :fantasy_cups_rounds

    belongs_to :fantasy_cup, class_name: '::FantasyCup', foreign_key: :cup_id
    belongs_to :week, class_name: '::Week', foreign_key: :week_id

    has_many :fantasy_cups_pairs, class_name: '::FantasyCups::Pair', foreign_key: :cups_round_id, dependent: :destroy
  end
end
