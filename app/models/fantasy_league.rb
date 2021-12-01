# frozen_string_literal: true

class FantasyLeague < ApplicationRecord
  belongs_to :leagueable, polymorphic: true
  belongs_to :season

  has_many :fantasy_leagues_teams, class_name: 'FantasyLeagues::Team', foreign_key: :fantasy_league_id, dependent: :destroy
  has_many :fantasy_teams, through: :fantasy_leagues_teams
end
