# frozen_string_literal: true

class Season < ApplicationRecord
  include Uuidable

  belongs_to :league

  has_many :seasons_teams, class_name: 'Seasons::Team', foreign_key: :season_id, dependent: :destroy
  has_many :teams, through: :seasons_teams
  has_many :active_teams_players, through: :seasons_teams

  has_many :weeks, dependent: :destroy
  has_one :active_week, -> { Week.active }, class_name: 'Week', foreign_key: :season_id # rubocop: disable Rails/HasManyOrHasOneDependent
  has_one :coming_week, -> { Week.coming }, class_name: 'Week', foreign_key: :season_id # rubocop: disable Rails/HasManyOrHasOneDependent

  has_many :all_fantasy_leagues, class_name: 'FantasyLeague', foreign_key: :season_id, dependent: :destroy
  has_many :fantasy_teams, -> { distinct }, through: :all_fantasy_leagues

  has_many :fantasy_leagues, as: :leagueable, dependent: :destroy

  has_many :players_seasons, class_name: 'Players::Season', dependent: :destroy
  has_many :players, through: :players_seasons

  scope :active, -> { where(active: true) }
end
