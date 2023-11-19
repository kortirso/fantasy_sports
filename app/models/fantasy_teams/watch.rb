# frozen_string_literal: true

module FantasyTeams
  class Watch < ApplicationRecord
    self.table_name = :fantasy_teams_watches

    belongs_to :fantasy_team, class_name: '::FantasyTeam', foreign_key: :fantasy_team_id
    belongs_to :players_season, class_name: '::Players::Season', foreign_key: :players_season_id
  end
end
