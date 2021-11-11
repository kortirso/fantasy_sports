# frozen_string_literal: true

module Teams
  class Player < ApplicationRecord
    self.table_name = :teams_players

    belongs_to :team
    belongs_to :player, class_name: '::Player'

    scope :active, -> { where(active: true) }
  end
end
