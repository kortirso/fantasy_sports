# frozen_string_literal: true

module Persisters
  module FantasyTeams
    class JoinFantasyLeagueService
      def call(fantasy_team:, fantasy_league_uuid: nil, invite_code: nil)
        fantasy_league = find_fantasy_league(fantasy_league_uuid, invite_code)
        return { errors: [I18n.t('controllers.fantasy_leagues.joins.not_found')] } if fantasy_league.nil?

        if FantasyLeagues::Team.exists?(fantasy_league: fantasy_league, pointable: fantasy_team)
          return { errors: [I18n.t('controllers.fantasy_leagues.joins.joined')] }
        end

        { result: fantasy_league.fantasy_leagues_teams.create!(pointable: fantasy_team) }
      end

      private

      def find_fantasy_league(fantasy_league_uuid, invite_code)
        FantasyLeague.find_by(uuid: fantasy_league_uuid) ||
          FantasyLeague.invitational.where.not(invite_code: nil).find_by(invite_code: invite_code)
      end
    end
  end
end
