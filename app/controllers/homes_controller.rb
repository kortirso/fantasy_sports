# frozen_string_literal: true

class HomesController < ApplicationController
  before_action :find_leagues

  def show; end

  private

  def find_leagues
    @seasons = Season.active.includes(:league).order('leagues.id ASC')
    @seasons = @seasons.where(leagues: { sport_kind: League.sport_kinds[params['sport_kind']] }) if params['sport_kind']
  end
end
