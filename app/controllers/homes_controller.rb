# frozen_string_literal: true

class HomesController < ApplicationController
  before_action :find_seasons
  before_action :find_user_fantasy_teams

  def show; end

  private

  def find_seasons
    @seasons = Season.active.includes(:league).order('leagues.id ASC')
    @seasons = @seasons.where(leagues: { sport_kind: League.sport_kinds[params['sport_kind']] }) if params['sport_kind']
    @seasons = @seasons.hashable_pluck(:id, :uuid, 'leagues.sport_kind', 'leagues.name')
  end

  def find_user_fantasy_teams
    @user_fantasy_teams =
      FantasyTeam
        .where(user: Current.user, season_id: @seasons.pluck(:id))
        .hashable_pluck(:uuid, :name, :completed, :season_id)
  end
end
