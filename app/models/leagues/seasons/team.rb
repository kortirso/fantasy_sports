# frozen_string_literal: true

module Leagues
  module Seasons
    class Team < ApplicationRecord
      self.table_name = :leagues_seasons_teams

      belongs_to :leagues_season, class_name: 'Leagues::Season'
      belongs_to :team, class_name: '::Team'
    end
  end
end
