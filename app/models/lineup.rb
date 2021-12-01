# frozen_string_literal: true

class Lineup < ApplicationRecord
  belongs_to :week
  belongs_to :fantasy_team

  has_many :lineups_players, class_name: '::Lineups::Player', foreign_key: :lineup_id, dependent: :destroy
  has_many :teams_player, through: :lineups_players
end
