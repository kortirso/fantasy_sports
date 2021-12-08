# frozen_string_literal: true

module Lineups
  module Players
    class UpdatePointsJob < ApplicationJob
      queue_as :default

      def perform(teams_players_points:, week_id:)
        Lineups::Players::UpdatePointsService.call(teams_players_points: JSON.parse(teams_players_points), week_id: week_id)
      end
    end
  end
end
