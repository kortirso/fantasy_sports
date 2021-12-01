# frozen_string_literal: true

module Lineups
  class Player < ApplicationRecord
    self.table_name = :lineups_players

    belongs_to :lineup, class_name: '::Lineup', foreign_key: :lineup_id
    belongs_to :teams_player, class_name: '::Teams::Player', foreign_key: :teams_player_id

    scope :active, -> { where(active: true) }
    scope :inactive, -> { where(active: false) }
  end
end
