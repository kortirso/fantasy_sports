# frozen_string_literal: true

module Leagues
  class Season < ApplicationRecord
    self.table_name = :leagues_seasons

    include Uuidable

    belongs_to :league

    has_many :leagues_seasons_teams, class_name: 'Leagues::Seasons::Team', foreign_key: :leagues_season_id, dependent: :destroy
    has_many :teams, through: :leagues_seasons_teams
    has_many :active_teams_players, through: :leagues_seasons_teams

    has_many :weeks, foreign_key: :leagues_season_id, dependent: :destroy

    has_many :all_fantasy_leagues, class_name: '::FantasyLeague', foreign_key: :leagues_season_id, dependent: :destroy
    has_many :fantasy_teams, through: :all_fantasy_leagues

    has_many :fantasy_leagues, as: :leagueable, dependent: :destroy

    scope :active, -> { where(active: true) }
  end
end
