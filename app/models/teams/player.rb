# frozen_string_literal: true

module Teams
  class Player < ApplicationRecord
    self.table_name = :teams_players

    belongs_to :seasons_team, class_name: '::Seasons::Team'
    belongs_to :player, class_name: '::Player'

    has_many :games_players, class_name: '::Games::Player', foreign_key: :teams_player_id, dependent: :destroy
    has_many :games, through: :games_players

    has_many :fantasy_teams_players, class_name: 'FantasyTeams::Player', foreign_key: :teams_player_id, dependent: :destroy
    has_many :fantasy_teams, through: :fantasy_teams_players

    has_many :lineups_players, class_name: '::Lineups::Player', foreign_key: :teams_player_id, dependent: :destroy
    has_many :lineups, through: :lineups_players

    delegate :team, to: :seasons_team

    scope :active, -> { where(active: true) }
  end
end
