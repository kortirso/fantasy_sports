# frozen_string_literal: true

module Games
  class Player < ApplicationRecord
    self.table_name = :games_players

    belongs_to :game
    belongs_to :player, class_name: '::Player'
  end
end
