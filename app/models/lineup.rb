# frozen_string_literal: true

class Lineup < ApplicationRecord
  include Uuidable

  belongs_to :week
  belongs_to :fantasy_team

  has_many :lineups_players, class_name: '::Lineups::Player', foreign_key: :lineup_id, dependent: :destroy
  has_many :teams_players, through: :lineups_players

  has_many :fantasy_leagues_teams,
           class_name: 'FantasyLeagues::Team',
           as: :pointable,
           dependent: :destroy
  has_many :fantasy_leagues, through: :fantasy_leagues_teams

  has_many :transfers, dependent: :destroy

  scope :with_final_points, -> { where(final_points: true) }
  scope :without_final_points, -> { where(final_points: false) }
end
