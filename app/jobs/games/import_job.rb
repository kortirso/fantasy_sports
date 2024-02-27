# frozen_string_literal: true

module Games
  class ImportJob < ApplicationJob
    queue_as :default

    def perform(game_ids:, main_external_source:)
      week = nil

      Game.where(id: game_ids).each.with_index do |game, index|
        # delay for api restrictions on production
        sleep 20 if index.positive? && Rails.env.production?

        Games::ImportService.call(game: game, main_external_source: main_external_source)
        week ||= game.week
      end
      return unless week

      ::Lineups::Players::Points::UpdateJob.perform_later(
        team_player_ids: week.teams_players.ids,
        week_id: week.id
      )

      ::Oraculs::Lineups::Points::UpdateJob.perform_later(
        week_id: week.id
      )
    end
  end
end
