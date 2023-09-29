# frozen_string_literal: true

module FantasyLeagues
  class CreateForm
    prepend ApplicationService
    include Validateable

    def initialize(
      league_join_service: JoinService
    )
      @league_join_service = league_join_service
    end

    def call(fantasy_team:, leagueable:, params:)
      return if validate_with(validator, params) && failure?

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
        season_id: @fantasy_team.season_id,
        global: global_league?
      )
      @result = FantasyLeague.create!(params)
    end

    def attach_fantasy_team_to_league
      @league_join_service.call(fantasy_team: @fantasy_team, fantasy_league: @result)
    end

    def global_league?
      !@leagueable.is_a?(User)
    end

    def validator = FantasySports::Container['validators.fantasy_league']
  end
end
