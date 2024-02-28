# frozen_string_literal: true

module Views
  module Shared
    class OraculStatisticComponent < ApplicationViewComponent
      def initialize(oracul:, periodable: nil)
        @oracul = oracul
        @periodable = periodable
        @placeable = oracul.oracul_place.placeable

        super()
      end

      def overall_points
        @overall_points ||= @oracul.points
      end

      def overall_rank
        oraculs_leagues[0][:place]
      end

      def oraculs_amount
        @placeable.oraculs.size
      end

      def oraculs_leagues
        @oraculs_leagues ||=
          @oracul
            .oracul_leagues_members
            .joins(:oracul_league)
            .order('oracul_leagues.id ASC')
            .hashable_pluck('oracul_leagues.uuid', 'oracul_leagues.name', :current_place)
            .map do |member|
              {
                uuid: member[:oracul_leagues_uuid],
                name: member[:oracul_leagues_name],
                place: member[:current_place]
              }
            end
      end
    end
  end
end
