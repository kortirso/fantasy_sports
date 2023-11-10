# frozen_string_literal: true

module Persisters
  module FantasyTeams
    class JoinFantasyLeagueService
      def call(fantasy_team:, fantasy_league:)
        fantasy_league.fantasy_leagues_teams.create!(pointable: fantasy_team)
      end
    end
  end
end
