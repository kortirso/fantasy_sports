# frozen_string_literal: true

module Leagues
  class Season < ApplicationRecord
    self.table_name = :leagues_seasons

    belongs_to :league

    has_many :leagues_seasons_teams, class_name: 'Leagues::Seasons::Team', inverse_of: :leagues_season, dependent: :destroy
    has_many :teams, through: :leagues_seasons_teams

    has_many :weeks, foreign_key: :leagues_season_id, dependent: :destroy

    has_many :all_fantasy_leagues, class_name: '::FantasyLeague', foreign_key: :leagues_season_id, dependent: :destroy
    has_many :users_teams, through: :all_fantasy_leagues

    has_many :fantasy_leagues, as: :leagueable, dependent: :destroy
  end
end
