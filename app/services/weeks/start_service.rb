# frozen_string_literal: true

module Weeks
  class StartService
    prepend ApplicationService

    GENERATE_WEEK_POSITION = 3

    def initialize(
      price_change_service: Teams::Players::Price::ChangeService,
      form_change_service: Teams::Players::Form::ChangeService,
      cup_create_service: Cups::CreateService,
      cups_pairs_generate_service: Cups::Pairs::GenerateService,
      generate_week_position: GENERATE_WEEK_POSITION
    )
      @price_change_service = price_change_service
      @form_change_service = form_change_service
      @cup_create_service = cup_create_service
      @cups_pairs_generate_service = cups_pairs_generate_service
      @generate_week_position = generate_week_position
    end

    def call(week:)
      return if week.nil?
      return unless week.coming?

      week.update!(status: Week::ACTIVE)
      change_price_for_teams_players(week)
      change_form_for_teams_players(week)
      generate_cups(week)
      generate_cups_pairs(week)
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

    def generate_cups(week)
      return if week.position != @generate_week_position

      week.season.all_fantasy_leagues.general.each do |fantasy_league|
        next if fantasy_league.cup

        @cup_create_service.call(fantasy_league: fantasy_league)
      end
    end

    def generate_cups_pairs(week)
      @cups_pairs_generate_service.call(week: week) if week.position > @generate_week_position
    end
  end
end
