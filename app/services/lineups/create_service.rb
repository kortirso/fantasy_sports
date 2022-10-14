# frozen_string_literal: true

module Lineups
  class CreateService
    prepend ApplicationService

    def initialize(
      lineup_players_creator: Lineups::Players::CreateService,
      lineup_players_copier:  Lineups::Players::CopyService
    )
      @lineup_players_creator = lineup_players_creator
      @lineup_players_copier  = lineup_players_copier
    end

    def call(fantasy_team:, week: nil)
      week ||= fantasy_team.fantasy_leagues.first.season.weeks.coming.first
      @result = Lineup.create!(fantasy_team: fantasy_team, week: week)

      add_lineup_players(fantasy_team, week)
    rescue ActiveRecord::RecordNotUnique
      fail!(I18n.t('services.fantasy_teams.lineups.create.record_exists'))
    end

    private

    def add_lineup_players(fantasy_team, week)
      previous_lineup = fantasy_team.lineups.find_by(week: week.previous)
      return @lineup_players_creator.call(lineup: @result) if previous_lineup.nil?

      @lineup_players_copier.call(lineup: @result, previous_lineup: previous_lineup)
    end
  end
end
