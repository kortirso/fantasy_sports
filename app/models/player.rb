# frozen_string_literal: true

class Player < ApplicationRecord
  belongs_to :sports_position, class_name: 'Sports::Position'

  has_many :teams_players, class_name: 'Teams::Player', dependent: :destroy
  has_many :seasons_teams, through: :teams_players

  has_one :active_teams_player, -> { Teams::Player.active }, class_name: 'Teams::Player'
  has_one :active_seasons_team, through: :active_teams_player, source: :seasons_team

  delegate :sport, to: :sports_position
  delegate :team, to: :active_seasons_team
end
