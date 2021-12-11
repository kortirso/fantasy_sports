# frozen_string_literal: true

module Lineups
  class UpdatePointsService
    prepend ApplicationService

    def call(lineup_ids:)
      Lineup
        .where(id: lineup_ids)
        .includes(:lineups_players)
        .each { |lineup| lineup.update(points: lineup.lineups_players.pluck(:points).sum(&:to_i)) }
    end
  end
end
