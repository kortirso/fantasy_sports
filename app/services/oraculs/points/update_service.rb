# frozen_string_literal: true

module Oraculs
  module Points
    class UpdateService
      def call(oracul_ids:)
        oraculs =
          Oracul
            .where(id: oracul_ids)
            .includes(:oraculs_lineups)
            .map do |oracul|
              {
                id: oracul.id,
                points: oracul.oraculs_lineups.pluck(:points).sum,
                uuid: oracul.uuid,
                user_id: oracul.user_id,
                oracul_place_id: oracul.oracul_place_id
              }
            end
        # commento: oraculs.points
        Oracul.upsert_all(oraculs) if oraculs.any?
      end
    end
  end
end
