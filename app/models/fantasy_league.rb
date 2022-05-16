# frozen_string_literal: true

class FantasyLeague < ApplicationRecord
  include Uuidable

  belongs_to :leagueable, polymorphic: true
  belongs_to :season

  has_many :fantasy_leagues_teams,
           class_name:  'FantasyLeagues::Team',
           foreign_key: :fantasy_league_id,
           dependent:   :destroy

  has_many :fantasy_teams, through: :fantasy_leagues_teams, source: :pointable, source_type: 'FantasyTeam'
  has_many :lineups, through: :fantasy_leagues_teams, source: :pointable, source_type: 'Lineup'

  def members
    leagueable_type == 'Week' ? lineups : fantasy_teams
  end
end
