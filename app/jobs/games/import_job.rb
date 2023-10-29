# frozen_string_literal: true

module Games
  class ImportJob < ApplicationJob
    queue_as :default

    def perform(game_ids:)
      team_player_ids = []
      week_id = nil

      Game.where(id: game_ids).each do |game|
        Games::ImportService.call(game: game)
        team_player_ids.push(game.games_players.pluck(:teams_player_id))
        week_id ||= game.week_id
      end
      return unless week_id

      ::Lineups::Players::Points::UpdateJob.perform_later(
        team_player_ids: team_player_ids.flatten,
        week_id: week_id
      )
    end
  end
end
