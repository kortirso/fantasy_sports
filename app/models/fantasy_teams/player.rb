# frozen_string_literal: true

module FantasyTeams
  class Player < ApplicationRecord
    self.table_name = :fantasy_teams_players

    belongs_to :fantasy_team, class_name: '::FantasyTeam', foreign_key: :fantasy_team_id, touch: true
    belongs_to :teams_player, class_name: '::Teams::Player', foreign_key: :teams_player_id
  end
end
