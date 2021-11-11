# frozen_string_literal: true

module Sports
  class Position < ApplicationRecord
    self.table_name = :sports_positions

    belongs_to :sport

    has_many :players, inverse_of: :sports_position, foreign_key: :sports_position_id, dependent: :nullify
  end
end
