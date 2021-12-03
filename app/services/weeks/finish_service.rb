# frozen_string_literal: true

module Weeks
  class FinishService
    prepend ApplicationService

    def call(week:)
      return if week.nil?

      week.update(status: Week::INACTIVE)
    end
  end
end
