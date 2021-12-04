# frozen_string_literal: true

module Games
  class Player < ApplicationRecord
    self.table_name = :games_players

    include Positionable

    belongs_to :game
    belongs_to :teams_player, class_name: '::Teams::Player'
  end
end
