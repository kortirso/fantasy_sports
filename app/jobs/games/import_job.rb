# frozen_string_literal: true

module Games
  class ImportJob < ApplicationJob
    queue_as :default

    def perform(game_ids:)
      week = nil

      Game.where(id: game_ids).each do |game|
        Games::ImportService.call(game: game)
        week ||= game.week
      end
      return unless week

      ::Lineups::Players::Points::UpdateJob.perform_later(
        team_player_ids: week.teams_players.ids,
        week_id: week.id
      )
    end
  end
end
