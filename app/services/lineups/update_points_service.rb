# frozen_string_literal: true

module Lineups
  class UpdatePointsService
    prepend ApplicationService

    def call(lineup_ids:)
      Lineup
        .where(id: lineup_ids)
        .each { |lineup| lineup.update(points: lineup.lineups_players.active.pluck(:points).sum(&:to_i)) }
    end
  end
end
