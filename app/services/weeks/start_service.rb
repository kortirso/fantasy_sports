# frozen_string_literal: true

module Weeks
  class StartService
    prepend ApplicationService

    GENERATE_WEEK_POSITION = 3

    def initialize(
      price_change_service: Teams::Players::Price::ChangeService,
      cup_create_service: Cups::CreateService,
      cups_pairs_generate_service: Cups::Pairs::GenerateService,
      generate_week_position: GENERATE_WEEK_POSITION
    )
      @price_change_service = price_change_service
      @cup_create_service = cup_create_service
      @cups_pairs_generate_service = cups_pairs_generate_service
      @generate_week_position = generate_week_position
    end

    def call(week:)
      return if week.nil?
      return unless week.coming?

      week.update!(status: Week::ACTIVE)
      change_price_for_teams_players(week)
      generate_cups(week)
      generate_cups_pairs(week)
      add_week_fantasy_league(week)
    end

    private

    def change_price_for_teams_players(week)
      @price_change_service.call(week: week)
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

    def add_week_fantasy_league(week)
      fantasy_league = FantasyLeague.create!(leagueable: week, season: week.season, name: "Week #{week.position}")

      members = week.lineups.ids.map do |lineup_id|
        {
          pointable_id: lineup_id,
          pointable_type: 'Lineup',
          fantasy_league_id: fantasy_league.id
        }
      end
      FantasyLeagues::Team.upsert_all(members) if members.any?
    end
  end
end
