# frozen_string_literal: true

module PageWrappers
  class PageComponent < ApplicationViewComponent
    def initialize(fantasy_team: nil, oracul: nil)
      @fantasy_team = fantasy_team
      @oracul = oracul
      @unread_achievements_count = Current.user.kudos_users_achievements.unread.count

      super()
    end

    def global_user_fantasy_teams
      @global_user_fantasy_teams ||=
        Current.user
          .fantasy_teams
          .completed
          .hashable_pluck(:uuid, :name, :season_id)
    end

    def global_user_oraculs
      @global_user_oraculs ||=
        Current.user
          .oraculs
          .joins(:oracul_place)
          .where(oracul_places: { active: true })
          .hashable_pluck(:uuid, :name, :placeable_id, :placeable_type)
    end

    private

    def background_urls
      @background_urls ||=
        {
          'Season' => Season.joins(:league).pluck(:id, 'leagues.slug').to_h.symbolize_keys,
          'Cup' => Cup.joins(:league).pluck(:id, 'leagues.slug').to_h.symbolize_keys
        }
    end
  end
end
