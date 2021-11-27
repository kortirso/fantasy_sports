# frozen_string_literal: true

module FantasyTeams
  class Lineup < ApplicationRecord
    self.table_name = :fantasy_teams_lineups

    belongs_to :week, class_name: '::Week'
    belongs_to :fantasy_team, class_name: '::FantasyTeam'

    has_many :fantasy_teams_lineups_players, class_name: '::FantasyTeams::Lineups::Player', foreign_key: :fantasy_teams_lineup_id, dependent: :destroy
    has_many :teams_player, through: :fantasy_teams_lineups_players
  end
end
