# frozen_string_literal: true

module Games
  class ImportJob < ApplicationJob
    queue_as :default

    def perform(game_id:)
      game = Game.find_by(id: game_id)
      return unless game

      Games::ImportService.call(game: game)
    end
  end
end
