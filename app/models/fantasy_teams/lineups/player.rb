# frozen_string_literal: true

module FantasyTeams
  module Lineups
    class Player < ApplicationRecord
      self.table_name = :fantasy_teams_lineups_players

      belongs_to :fantasy_teams_lineup, class_name: '::FantasyTeams::Lineup', foreign_key: :fantasy_teams_lineup_id
      belongs_to :teams_player, class_name: '::Teams::Player', foreign_key: :teams_player_id

      scope :active, -> { where(active: true) }
      scope :inactive, -> { where(active: false) }
    end
  end
end
