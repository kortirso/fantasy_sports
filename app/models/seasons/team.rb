# frozen_string_literal: true

module Seasons
  class Team < ApplicationRecord
    self.table_name = :seasons_teams

    belongs_to :season, class_name: '::Season'
    belongs_to :team, class_name: '::Team'

    has_many :teams_players, class_name: '::Teams::Player', foreign_key: :seasons_team_id, dependent: :destroy
    has_many :players, through: :teams_players

    # rubocop: disable Rails/HasManyOrHasOneDependent
    has_many :active_teams_players,
             -> { Teams::Player.active },
             foreign_key: :seasons_team_id,
             class_name:  'Teams::Player'
    has_many :active_players, through: :active_teams_players, source: :player

    has_many :games, lambda { |season_team|
      unscope(:where).where(home_season_team: season_team).or(where(visitor_season_team: season_team))
    }
    # rubocop: enable Rails/HasManyOrHasOneDependent
    has_many :home_season_games, class_name: 'Game', foreign_key: :home_season_team_id, dependent: :destroy
    has_many :visitor_season_games, class_name: 'Game', foreign_key: :visitor_season_team_id, dependent: :destroy
  end
end
