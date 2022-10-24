# frozen_string_literal: true

module FantasyLeagues
  class CreateService
    prepend ApplicationService

    def initialize(
      fantasy_league_validator: FantasyLeagueValidator,
      league_join_service:      JoinService
    )
      @fantasy_league_validator = fantasy_league_validator
      @league_join_service      = league_join_service
    end

    def call(fantasy_team:, leagueable:, params:)
      return if validate_with(@fantasy_league_validator, params) && failure?

      @fantasy_team = fantasy_team
      @leagueable = leagueable

      ActiveRecord::Base.transaction do
        create_fantasy_league(params)
        attach_fantasy_team_to_league
      end
    end

    private

    def create_fantasy_league(params)
      params.merge!(
        leagueable: @leagueable,
        season: @fantasy_team.fantasy_leagues.first.season,
        global: global_league?,
        invite_code: global_league? ? nil : SecureRandom.hex
      )
      @result = FantasyLeague.create!(params)
    end

    def attach_fantasy_team_to_league
      @league_join_service.call(fantasy_team: @fantasy_team, fantasy_league: @result)
    end

    def global_league?
      !@leagueable.is_a?(User)
    end
  end
end
