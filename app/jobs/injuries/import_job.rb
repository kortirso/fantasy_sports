# frozen_string_literal: true

module Injuries
  class ImportJob < ApplicationJob
    queue_as :default

    def perform(import_service: Injuries::ImportService.new)
      Season.in_progress.each do |season|
        import_service.call(season: season)
      end
    end
  end
end
