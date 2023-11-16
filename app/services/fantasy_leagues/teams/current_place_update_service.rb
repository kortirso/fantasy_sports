# frozen_string_literal: true

module FantasyLeagues
  module Teams
    class CurrentPlaceUpdateService
      def call(fantasy_league:)
        fantasy_leagues_teams = fantasy_league.fantasy_leagues_teams.pluck(:pointable_id, :id).to_h

        objects =
          fantasy_league
            .members
            .order(points: :desc)
            .hashable_pluck(:id, :points)
            .map.with_index(1) do |member, index|
              {
                id: fantasy_leagues_teams[member[:id]],
                current_place: index,
                fantasy_league_id: fantasy_league.id,
                pointable_id: member[:id],
                pointable_type: fantasy_league.for_week? ? 'Lineup' : 'FantasyTeam'
              }
            end
        # commento: fantasy_leagues_teams.current_place
        FantasyLeagues::Team.upsert_all(objects) if objects.any?
      end
    end
  end
end
