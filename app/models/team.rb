# frozen_string_literal: true

class Team < ApplicationRecord
  has_many :leagues_seasons_teams, class_name: 'Leagues::Seasons::Team', dependent: :destroy
  has_many :leagues_seasons, through: :leagues_seasons_teams

  has_many :games, ->(team) {
    unscope(:where).where(home_team: team).or(where(visitor_team: team))
  }
  has_many :home_games, class_name: 'Game', foreign_key: :home_team_id, dependent: :destroy
  has_many :visitor_games, class_name: 'Game', foreign_key: :visitor_team_id, dependent: :destroy
end
