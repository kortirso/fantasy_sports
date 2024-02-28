# frozen_string_literal: true

module Persisters
  module Oraculs
    class JoinOraculLeagueService
      def call(oracul:, oracul_league_uuid: nil, invite_code: nil)
        oracul_league = find_oracul_league(oracul_league_uuid, invite_code)
        return { errors: [I18n.t('controllers.oracul_leagues.joins.not_found')] } if oracul_league.nil?

        if OraculLeagues::Member.exists?(oracul_league: oracul_league, oracul: oracul)
          return { errors: [I18n.t('controllers.oracul_leagues.joins.joined')] }
        end

        { result: oracul_league.oracul_leagues_members.create!(oracul: oracul) }
      end

      private

      def find_oracul_league(oracul_league_uuid, invite_code)
        OraculLeague.find_by(uuid: oracul_league_uuid) ||
          OraculLeague.invitational.where.not(invite_code: nil).find_by(invite_code: invite_code)
      end
    end
  end
end
