# frozen_string_literal: true

module Achievements
  class RefreshAfterGameJob < ApplicationJob
    queue_as :default

    def perform
      Achievements::Lineups::PointsJob.perform_later
    end
  end
end
