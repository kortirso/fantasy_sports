# frozen_string_literal: true

module Teams
  class Player < ApplicationRecord
    self.table_name = :teams_players

    belongs_to :leagues_seasons_team, class_name: '::Leagues::Seasons::Team'
    belongs_to :player, class_name: '::Player'

    has_many :games_players, class_name: '::Games::Player', foreign_key: :teams_player_id, dependent: :destroy
    has_many :games, through: :games_players

    scope :active, -> { where(active: true) }
  end
end
