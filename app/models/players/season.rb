# frozen_string_literal: true

module Players
  # statistic of players for finished seasons
  class Season < ApplicationRecord
    self.table_name = :players_seasons

    include Uuidable

    belongs_to :player, class_name: '::Player'
    belongs_to :season, class_name: '::Season'

    has_many :teams_players, class_name: '::Teams::Player', foreign_key: :players_season_id, dependent: :destroy
    has_many :games_players, through: :teams_players

    has_many :fantasy_teams_watches,
             class_name: 'FantasyTeams::Watch',
             foreign_key: :players_season_id,
             dependent: :destroy

    # rubocop: disable Rails/HasManyOrHasOneDependent
    has_one :active_teams_player,
            -> { Teams::Player.active },
            foreign_key: :players_season_id,
            class_name: '::Teams::Player'
    # rubocop: enable Rails/HasManyOrHasOneDependent

    has_many :injuries, foreign_key: :players_season_id, dependent: :destroy
  end
end
