# frozen_string_literal: true

module Weeks
  class StartService
    prepend ApplicationService

    def initialize(
      price_change_service: Teams::Players::Price::ChangeService,
      form_change_service:  Teams::Players::Form::ChangeService
    )
      @price_change_service = price_change_service
      @form_change_service = form_change_service
    end

    def call(week:)
      return if week.nil?
      return unless week.coming?

      week.update!(status: Week::ACTIVE)
      change_price_for_teams_players(week)
      change_form_for_teams_players(week)
    end

    private

    def change_price_for_teams_players(week)
      @price_change_service.call(week: week)
    end

    def change_form_for_teams_players(week)
      @form_change_service.call(
        games_ids: Game.where(week_id: week.weeks_ids_for_form_calculation).order(id: :asc).ids
      )
    end
  end
end
