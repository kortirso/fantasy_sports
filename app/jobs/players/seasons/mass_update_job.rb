# frozen_string_literal: true

module Players
  module Seasons
    class MassUpdateJob < ApplicationJob
      queue_as :default

      def perform(season_id:, player_ids:)
        Players::Seasons::MassUpdateService.call(
          season_id: season_id,
          player_ids: player_ids
        )
      end
    end
  end
end
