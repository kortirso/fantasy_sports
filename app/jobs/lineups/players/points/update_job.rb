# frozen_string_literal: true

module Lineups
  module Players
    module Points
      class UpdateJob < ApplicationJob
        queue_as :default

        def perform(team_player_ids:, week_id:)
          Lineups::Players::Points::UpdateService.call(
            team_player_ids: team_player_ids,
            week_id: week_id
          )

          Week.find_by(id: week_id)&.season&.all_fantasy_leagues&.each do |fantasy_league|
            update_service.call(fantasy_league: fantasy_league)
          end
        end

        private

        def update_service = FantasySports::Container['services.fantasy_leagues.teams.update_current_place']
      end
    end
  end
end
