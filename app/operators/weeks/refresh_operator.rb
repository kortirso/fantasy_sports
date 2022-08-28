# frozen_string_literal: true

module Weeks
  class RefreshOperator < ApplicationOperator
    required_context :week

    around :use_transaction

    before :turn_off

    step :finish_week, with: Weeks::FinishService, week: :previous_week
    step :start_week, with: Weeks::StartService
    step :prepare_week, with: Weeks::ComingService, week: :next_week

    after :turn_on

    private

    def turn_off
      update_league_maintenance(true)
    end

    def turn_on
      update_league_maintenance(false)
    end

    def update_league_maintenance(maintenance)
      context.week.league.update!(maintenance: maintenance)
    end

    def previous_week
      context.week.previous
    end

    def next_week
      context.week.next
    end
  end
end
