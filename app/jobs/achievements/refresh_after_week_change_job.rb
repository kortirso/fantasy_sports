# frozen_string_literal: true

module Achievements
  class RefreshAfterWeekChangeJob < ApplicationJob
    queue_as :default

    def perform(week_id:)
      week = Week.coming.find_by(id: week_id)
      return unless week

      Achievements::Lineups::DiversityJob.perform_later(week_id: week.id)
      Achievements::Lineups::TopPointsJob.perform_later(week_id: week.previous.id)
    end
  end
end
