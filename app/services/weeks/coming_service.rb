# frozen_string_literal: true

module Weeks
  class ComingService
    prepend ApplicationService

    def initialize(
      lineup_create_service: Lineups::CreateService
    )
      @lineup_create_service = lineup_create_service
    end

    def call(week:)
      return if week.nil?
      return unless week.inactive?

      week.update!(status: Week::COMING)
      create_lineups(week)
    end

    private

    def create_lineups(week)
      week.season.fantasy_teams.completed.find_each { |fantasy_team|
        @lineup_create_service.call(fantasy_team: fantasy_team, week: week)
      }
    end
  end
end
