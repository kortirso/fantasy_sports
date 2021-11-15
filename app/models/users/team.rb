# frozen_string_literal: true

module Users
  class Team < ApplicationRecord
    self.table_name = :users_teams

    belongs_to :user

    has_many :fantasy_leagues_teams, class_name: 'FantasyLeagues::Team', foreign_key: :users_team_id, dependent: :destroy
    has_many :fantasy_leagues, through: :fantasy_leagues_teams
  end
end
