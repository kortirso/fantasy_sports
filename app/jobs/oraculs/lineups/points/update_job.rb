# frozen_string_literal: true

module Oraculs
  module Lineups
    module Points
      class UpdateJob < ApplicationJob
        queue_as :default

        def perform(week_id:)
          update_points.call(week_id: week_id)

          Week.find_by(id: week_id)&.season&.oracul_leagues&.each do |oracul_league|
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
