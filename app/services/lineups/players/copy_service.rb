# frozen_string_literal: true

module Lineups
  module Players
    # Service for copying previous lineup players with all properties to new week lineup
    # This service usually run from second week
    # So users will have the same squad for new week
    class CopyService
      prepend ApplicationService

      def call(lineup:, previous_lineup:)
        Lineups::Player.upsert_all(
          previous_lineup
            .lineups_players
            .hashable_pluck(:teams_player_id, :change_order, :status)
            .map do |lineups_player|
              {
                teams_player_id: lineups_player[:teams_player_id],
                lineup_id: lineup.id,
                change_order: lineups_player[:change_order],
                status: lineups_player[:status]
              }
            end
        )
      end
    end
  end
end
