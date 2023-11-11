# frozen_string_literal: true

module Games
  class DifficultyUpdateJob < ApplicationJob
    queue_as :default

    def perform(week_id:)
      week = Week.find_by(id: week_id)
      return unless week

      Games::DifficultyUpdateService.new.call(week: week)
    end
  end
end
