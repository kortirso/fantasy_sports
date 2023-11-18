# frozen_string_literal: true

module Weeks
  class BenchSubstitutionsJob < ApplicationJob
    queue_as :default

    def perform
      Week.active.each do |week|
        next if week.games.exists?(points: [])
        next if week.games.maximum(:start_at) > 1.day.before

        FantasySports::Container['services.weeks.bench_substitutions'].call(week: week)
      end
    end
  end
end
