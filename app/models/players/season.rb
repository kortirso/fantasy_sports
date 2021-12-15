# frozen_string_literal: true

module Players
  # statistic of players for finished seasons
  class Season < ApplicationRecord
    self.table_name = :players_seasons

    belongs_to :player, class_name: '::Player'
    belongs_to :season, class_name: '::Season'
  end
end
