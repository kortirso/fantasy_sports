# frozen_string_literal: true

module Watchable
  extend ActiveSupport::Concern

  private

  def set_watchable_players
    return if Current.user.blank?
    return if @fantasy_team.nil?

    user_fantasy_team =
      if @fantasy_team.user_id == Current.user.id
        @fantasy_team
      else
        FantasyTeam.joins(:season).find_by(seasons: { id: @fantasy_team.season_id })
      end

    @watches = user_fantasy_team.fantasy_teams_watches.joins(:players_season).pluck('players_seasons.uuid')
  end
end
