# frozen_string_literal: true

module OraculLeagues
  module Members
    class CurrentPlaceUpdateService
      def call(oracul_league:)
        oracul_leagues_members = oracul_league.oracul_leagues_members.pluck(:oracul_id, :id).to_h

        objects =
          oracul_league
            .oraculs
            .order(points: :desc)
            .hashable_pluck(:id, :points)
            .map.with_index(1) do |member, index|
              {
                id: oracul_leagues_members[member[:id]],
                current_place: index,
                oracul_league_id: oracul_league.id,
                oracul_id: member[:id]
              }
            end
        # commento: oracul_leagues_members.current_place
        OraculLeagues::Member.upsert_all(objects) if objects.any?
      end
    end
  end
end
