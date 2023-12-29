# frozen_string_literal: true

module Games
  class DifficultyUpdateJob < ApplicationJob
    queue_as :default

    def perform(week_id:)
      week = Week.find_by(id: week_id)
      return unless week

      update_service.call(week: week)
    end

    private

    def update_service = FantasySports::Container['services.games.difficulty_update']
  end
end
