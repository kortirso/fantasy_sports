# frozen_string_literal: true

module Games
  class Player < ApplicationRecord
    self.table_name = :games_players

    include Positionable
    include Statable
    include Uuidable

    belongs_to :game, touch: true
    belongs_to :teams_player, class_name: '::Teams::Player'
    belongs_to :seasons_team, class_name: '::Seasons::Team'
  end
end
