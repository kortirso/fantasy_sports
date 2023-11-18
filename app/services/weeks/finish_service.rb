# frozen_string_literal: true

module Weeks
  class FinishService
    include Deps[bench_substitutions_service: 'services.weeks.bench_substitutions']

    def call(week:)
      return if week.nil?
      return unless week.active?

      bench_substitutions_service.call(week: week)
      # commento: weeks.status
      week.update!(status: Week::FINISHED)
    end
  end
end
