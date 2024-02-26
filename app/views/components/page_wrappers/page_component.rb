# frozen_string_literal: true

module PageWrappers
  class PageComponent < ApplicationViewComponent
    def initialize(fantasy_team: nil)
      @fantasy_team = fantasy_team
      @unread_achievements_count = Current.user.kudos_users_achievements.unread.count

      super()
    end

    def global_user_fantasy_teams
      @global_user_fantasy_teams ||=
        Current.user
          .fantasy_teams.completed
          .joins(season: :league)
          .hashable_pluck(:uuid, :name, 'leagues.sport_kind')
    end

    def global_user_oraculs
      @global_user_oraculs ||=
        Current.user
          .oraculs
          .joins(:oracul_place)
          .where(oracul_places: { active: true })
          .hashable_pluck(:uuid, :name)
    end
  end
end
