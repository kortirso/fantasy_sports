# frozen_string_literal: true

module Cups
  class Round < ApplicationRecord
    self.table_name = :cups_rounds

    include Periodable

    COMING = 'coming'
    ACTIVE = 'active'
    FINISHED = 'finished'

    belongs_to :cup, class_name: '::Cup', foreign_key: :cup_id

    has_many :cups_pairs, class_name: '::Cups::Pair', foreign_key: :cups_round_id, dependent: :destroy

    enum status: { COMING => 0, ACTIVE => 1, FINISHED => 2 }
  end
end
