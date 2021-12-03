# frozen_string_literal: true

module Lineups
  class CreateService
    prepend ApplicationService

    def initialize(
      lineup_players_creator: Lineups::Players::CreateService
    )
      @lineup_players_creator = lineup_players_creator
    end

    def call(fantasy_team:, week: nil)
      week    ||= fantasy_team.fantasy_leagues.first.season.weeks.coming.first
      @record = Lineup.create(fantasy_team: fantasy_team, week: week)

      @lineup_players_creator.call(lineup: @record)
    rescue ActiveRecord::RecordNotUnique
      fail!(I18n.t('services.fantasy_teams.lineups.create.record_exists'))
    end
  end
end
