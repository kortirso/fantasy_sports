# frozen_string_literal: true

module Weeks
  class FinishService
    prepend ApplicationService

    def call(week:)
      return if week.nil?
      return unless week.active?

      week.update!(status: Week::FINISHED)
    end
  end
end
