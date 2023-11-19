# frozen_string_literal: true

module Watchable
  extend ActiveSupport::Concern

  private

  def set_watchable_players
    return if Current.user.blank?
    return if @fantasy_team.nil?
    return unless @fantasy_team.user_id == Current.user.id

    @watches = @fantasy_team.fantasy_teams_watches.joins(:players_season).pluck('players_seasons.uuid')
  end
end
