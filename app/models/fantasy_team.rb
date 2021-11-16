# frozen_string_literal: true

class FantasyTeam < ApplicationRecord
  belongs_to :user

  has_many :fantasy_leagues_teams, class_name: 'FantasyLeagues::Team', foreign_key: :fantasy_team_id, dependent: :destroy
  has_many :fantasy_leagues, through: :fantasy_leagues_teams

  has_many :fantasy_teams_players, class_name: 'FantasyTeams::Player', foreign_key: :fantasy_team_id, dependent: :destroy
  has_many :teams_players, through: :fantasy_teams_players
end
