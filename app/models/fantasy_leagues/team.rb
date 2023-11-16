# frozen_string_literal: true

module FantasyLeagues
  class Team < ApplicationRecord
    self.table_name = :fantasy_leagues_teams

    belongs_to :fantasy_league,
               class_name: '::FantasyLeague',
               foreign_key: :fantasy_league_id,
               counter_cache: :fantasy_leagues_teams_count
    belongs_to :pointable, polymorphic: true
  end
end
