# frozen_string_literal: true

class Team < ApplicationRecord
  has_many :leagues_seasons_teams, class_name: 'Leagues::Seasons::Team', dependent: :destroy
  has_many :leagues_seasons, through: :leagues_seasons_teams

  has_many :teams_players, class_name: 'Teams::Player', dependent: :destroy
  has_many :players, through: :teams_players

  has_many :active_teams_players, -> { Teams::Player.active }, class_name: 'Teams::Player'
  has_many :active_players, through: :active_teams_players, source: :player
end
