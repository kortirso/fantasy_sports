# frozen_string_literal: true

module Weeks
  class StartService
    prepend ApplicationService

    def call(week:)
      return if week.nil?

      week.update(status: Week::ACTIVE)
    end
  end
end
