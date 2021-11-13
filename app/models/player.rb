# frozen_string_literal: true

class Player < ApplicationRecord
  belongs_to :sports_position, class_name: 'Sports::Position'

  has_many :teams_players, class_name: 'Teams::Player', dependent: :destroy
  has_many :leagues_seasons_teams, through: :teams_players

  has_one :active_teams_player, -> { Teams::Player.active }, class_name: 'Teams::Player'
  has_one :active_leagues_seasons_team, through: :active_teams_player, source: :leagues_seasons_team

  has_many :games_players, class_name: 'Games::Player', dependent: :destroy
  has_many :games, through: :games_players

  delegate :sport, to: :sports_position
  delegate :team, to: :active_leagues_seasons_team
end
