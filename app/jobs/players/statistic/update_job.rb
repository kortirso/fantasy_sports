# frozen_string_literal: true

module Players
  module Statistic
    class UpdateJob < ApplicationJob
      queue_as :default

      def perform(season_id:, player_ids:)
        Players::Statistic::UpdateService.call(
          season_id:  season_id,
          player_ids: player_ids
        )
      end
    end
  end
end
