# frozen_string_literal: true

module Cups
  class Round < ApplicationRecord
    self.table_name = :cups_rounds

    belongs_to :cup, class_name: '::Cup', foreign_key: :cup_id
    belongs_to :week, class_name: '::Week', foreign_key: :week_id

    has_many :cups_pairs, class_name: '::Cups::Pair', foreign_key: :cups_round_id, dependent: :destroy
  end
end
