# frozen_string_literal: true

class FantasyTeam < ApplicationRecord
  include Uuidable
  include Sportable

  belongs_to :user

  has_many :fantasy_leagues_teams,
           class_name: 'FantasyLeagues::Team',
           as: :pointable,
           dependent: :destroy
  has_many :fantasy_leagues, through: :fantasy_leagues_teams

  has_many :fantasy_teams_players,
           class_name: 'FantasyTeams::Player',
           foreign_key: :fantasy_team_id,
           dependent: :destroy
  has_many :teams_players, through: :fantasy_teams_players

  has_many :lineups, dependent: :destroy
  has_many :weeks, through: :lineups

  scope :completed, -> { where(completed: true) }
end
