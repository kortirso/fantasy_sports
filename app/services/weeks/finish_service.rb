# frozen_string_literal: true

module Weeks
  class FinishService
    prepend ApplicationService

    def initialize(
      bench_substitutions_service: Lineups::BenchSubstitutionsService
    )
      @bench_substitutions_service = bench_substitutions_service
    end

    def call(week:)
      return if week.nil?
      return unless week.active?

      # commento: weeks.status
      week.update!(status: Week::FINISHED)
      make_bench_subsctitutions(week)
    end

    private

    def make_bench_subsctitutions(week)
      @bench_substitutions_service.call(week: week)
    end
  end
end
