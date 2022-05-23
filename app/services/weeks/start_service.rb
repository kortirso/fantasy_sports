# frozen_string_literal: true

module Weeks
  class StartService
    prepend ApplicationService

    def initialize(
      price_change_service: Teams::Players::Price::ChangeService
    )
      @price_change_service = price_change_service
    end

    def call(week:)
      return if week.nil?
      return unless week.coming?

      week.update!(status: Week::ACTIVE)
      update_transfers_limit_for_fantasy_teams(week)
      @price_change_service.call(week: week)
    end

    private

    def update_transfers_limit_for_fantasy_teams(week)
      free_transfers_per_week = Sports.sport(week.season.league.sport_kind)['free_transfers_per_week']
      week.fantasy_teams.with_unlimited_transfers.update_all(
        transfers_limited: true,
        free_transfers:    free_transfers_per_week
      )
    end
  end
end
