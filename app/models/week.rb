# frozen_string_literal: true

class Week < ApplicationRecord
  belongs_to :leagues_season, class_name: '::Leagues::Season'

  has_many :games, dependent: :destroy

  has_many :fantasy_leagues, as: :leagueable, dependent: :destroy

  has_many :fantasy_teams_lineups, class_name: 'FantasyTeams::Lineup', foreign_key: :week_id, dependent: :destroy
  has_many :fantasy_teams, through: :fantasy_teams_lineups

  enum status: { inactive: 0, coming: 1, active: 2 }
end
