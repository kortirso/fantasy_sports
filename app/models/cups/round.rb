# frozen_string_literal: true

module Cups
  class Round < ApplicationRecord
    self.table_name = :cups_rounds

    include Uuidable
    include Periodable

    COMING = 'coming'
    ACTIVE = 'active'
    FINISHED = 'finished'

    belongs_to :cup, class_name: '::Cup', foreign_key: :cup_id

    enum status: { COMING => 0, ACTIVE => 1, FINISHED => 2 }
  end
end
