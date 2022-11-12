# frozen_string_literal: true

module Lineups
  class Player < ApplicationRecord
    self.table_name = :lineups_players

    include Uuidable

    REGULAR = 'regular'
    ASSISTANT = 'assistant'
    CAPTAIN = 'captain'

    belongs_to :lineup, class_name: '::Lineup', foreign_key: :lineup_id
    belongs_to :teams_player, class_name: '::Teams::Player', foreign_key: :teams_player_id

    scope :active, -> { where(change_order: 0) }
    scope :inactive, -> { where.not(change_order: 0) }
    scope :not_captain, -> { where.not(status: CAPTAIN) }

    enum status: { REGULAR => 0, ASSISTANT => 1, CAPTAIN => 2 }

    def active?
      change_order.zero?
    end
  end
end
