# frozen_string_literal: true

module FantasyLeagues
  class JoinService
    prepend ApplicationService

    def call(fantasy_team:, fantasy_league:)
      fantasy_league.fantasy_leagues_teams.create!(pointable: fantasy_team)
    end
  end
end
