# frozen_string_literal: true

module Oraculs
  module Lineups
    module Points
      class UpdateJob < ApplicationJob
        queue_as :default

        def perform(periodable_id:, periodable_type:)
          update_points.call(periodable_id: periodable_id, periodable_type: periodable_type)
          periodable_type.constantize.find_by(id: periodable_id)&.placeable&.oracul_leagues&.each do |oracul_league|
            update_current_place.call(oracul_league: oracul_league)
          end
        end

        private

        def update_points = FantasySports::Container['services.oraculs.lineups.points.update']
        def update_current_place = FantasySports::Container['services.oracul_leagues.members.update_current_place']
      end
    end
  end
end
