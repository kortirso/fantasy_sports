# frozen_string_literal: true

module FantasyLeagues
  class CreateForm
    include Deps[
      validator: 'validators.fantasy_league',
      join_fantasy_league: 'services.persisters.fantasy_teams.join_fantasy_league'
    ]

    def call(fantasy_team:, leagueable:, params:)
      errors = validator.call(params: params)
      return { errors: errors } if errors.any?

      result = ActiveRecord::Base.transaction do
        fantasy_league = create_fantasy_league(leagueable, fantasy_team, params)
        attach_fantasy_team_to_league(fantasy_team, fantasy_league)
        fantasy_league
      end

      { result: result }
    end

    private

    def create_fantasy_league(leagueable, fantasy_team, params)
      params.merge!(
        leagueable: leagueable,
        season_id: fantasy_team.season_id,
        global: global_league?(leagueable)
      )
      # comment: fantasy_leagues.name
      FantasyLeague.create!(params)
    end

    def attach_fantasy_team_to_league(fantasy_team, fantasy_league)
      join_fantasy_league.call(fantasy_team: fantasy_team, fantasy_league: fantasy_league)
    end

    def global_league?(leagueable)
      !leagueable.is_a?(User)
    end
  end
end
