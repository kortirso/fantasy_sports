# frozen_string_literal: true

module Games
  class ImportJob < ApplicationJob
    queue_as :default

    def perform(game_ids:)
      Game.where(id: game_ids).each do |game|
        Games::ImportService.call(game: game)
      end
    end
  end
end
