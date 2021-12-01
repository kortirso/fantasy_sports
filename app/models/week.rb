# frozen_string_literal: true

class Week < ApplicationRecord
  belongs_to :season

  has_many :games, dependent: :destroy

  has_many :fantasy_leagues, as: :leagueable, dependent: :destroy

  has_many :lineups, dependent: :destroy
  has_many :fantasy_teams, through: :lineups

  enum status: { inactive: 0, coming: 1, active: 2 }
end
