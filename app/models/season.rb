# frozen_string_literal: true

class Season < ApplicationRecord
  include Uuidable
  include Leagueable
  include Placeable
  include Likeable

  INACTIVE = 'inactive'
  ACTIVE = 'active'
  FINISHING = 'finishing'
  FINISHED = 'finished'

  belongs_to :league

  has_many :seasons_teams, class_name: 'Seasons::Team', foreign_key: :season_id, dependent: :destroy
  has_many :teams, through: :seasons_teams
  has_many :teams_players, through: :seasons_teams
  has_many :active_teams_players, through: :seasons_teams

  has_many :weeks, dependent: :destroy
  has_one :active_week, -> { Week.active }, class_name: 'Week', foreign_key: :season_id # rubocop: disable Rails/HasManyOrHasOneDependent
  has_one :coming_week, -> { Week.coming }, class_name: 'Week', foreign_key: :season_id # rubocop: disable Rails/HasManyOrHasOneDependent

  has_many :games # rubocop: disable Rails/HasManyOrHasOneDependent

  has_many :all_fantasy_leagues, class_name: 'FantasyLeague', foreign_key: :season_id, dependent: :destroy
  has_many :fantasy_teams, dependent: :destroy

  has_many :players_seasons, class_name: 'Players::Season', dependent: :destroy
  has_many :players, through: :players_seasons
  has_many :injuries, through: :players_seasons

  scope :in_progress, -> { where(status: [ACTIVE, FINISHING]) }
  scope :coming, -> { where(status: INACTIVE).where.not(start_at: nil) }

  enum status: { INACTIVE => 0, ACTIVE => 1, FINISHING => 2, FINISHED => 3 }

  def in_progress?
    [ACTIVE, FINISHING].include?(status)
  end

  def open_transfers?
    [INACTIVE, ACTIVE].include?(status)
  end

  def closed_transfers?
    [FINISHING, FINISHED].include?(status)
  end
end
