# frozen_string_literal: true

module Injuries
  class RemoveExpiredJob < ApplicationJob
    queue_as :default

    def perform
      Injury.inactive.destroy_all
    end
  end
end
