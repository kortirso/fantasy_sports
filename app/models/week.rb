# frozen_string_literal: true

class Week < ApplicationRecord
  include Leagueable
  include Uuidable

  INACTIVE = 'inactive'
  COMING   = 'coming'
  ACTIVE   = 'active'
  FINISHED = 'finished'

  belongs_to :season, touch: true

  has_many :games, dependent: :destroy
  has_many :games_players, through: :games

  has_many :lineups, dependent: :destroy
  has_many :fantasy_teams, through: :lineups
  has_many :teams_players, through: :lineups
  has_many :transfers, through: :lineups

  has_many :cups_rounds, class_name: '::Cups::Round', dependent: :destroy
  has_many :cups_pairs, class_name: '::Cups::Pair', through: :cups_rounds

  scope :active, -> { where(status: ACTIVE) }
  scope :opponent_visible, -> { where(status: [ACTIVE, FINISHED]) }

  enum status: { INACTIVE => 0, COMING => 1, ACTIVE => 2, FINISHED => 3 }

  delegate :league, to: :season

  def previous
    Week.find_by(season_id: season_id, position: position - 1)
  end

  def next
    Week.find_by(season_id: season_id, position: position + 1)
  end

  def weeks_ids_for_form_calculation
    Week
      .where(season_id: season_id)
      .where('position <= ?', position)
      .where('position > 0')
      .order(position: :desc)
      .ids
      .first(Teams::Player::WEEKS_COUNT_FOR_FORM_CALCULATION)
  end

  def opponent_visible?
    status == ACTIVE || status == FINISHED
  end
end
