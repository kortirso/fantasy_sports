# frozen_string_literal: true

module Leagues
  module Seasons
    class Team < ApplicationRecord
      self.table_name = :leagues_seasons_teams

      belongs_to :leagues_season, class_name: 'Leagues::Season'
      belongs_to :team, class_name: '::Team'

      has_many :teams_players, class_name: '::Teams::Player', foreign_key: :leagues_seasons_team_id, dependent: :destroy
      has_many :players, through: :teams_players

      has_many :active_teams_players, -> { Teams::Player.active }, foreign_key: :leagues_seasons_team_id, class_name: 'Teams::Player'
      has_many :active_players, through: :active_teams_players, source: :player

      has_many :games, ->(leagues_season_team) {
        unscope(:where).where(home_season_team: leagues_season_team).or(where(visitor_season_team: leagues_season_team))
      }
      has_many :home_season_games, class_name: 'Game', foreign_key: :home_season_team_id, dependent: :destroy
      has_many :visitor_season_games, class_name: 'Game', foreign_key: :visitor_season_team_id, dependent: :destroy
    end
  end
end
