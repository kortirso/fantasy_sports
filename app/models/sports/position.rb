# frozen_string_literal: true

module Sports
  class Position < ApplicationRecord
    self.table_name = :sports_positions

    belongs_to :sport
  end
end
