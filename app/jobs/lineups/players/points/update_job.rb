# frozen_string_literal: true

module Lineups
  module Players
    module Points
      class UpdateJob < ApplicationJob
        queue_as :default

        def perform(team_player_ids:, week_id:)
          Lineups::Players::Points::UpdateService.call(
            team_player_ids: team_player_ids,
            week_id:         week_id
          )
        end
      end
    end
  end
end
