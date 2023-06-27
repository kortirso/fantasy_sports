# frozen_string_literal: true

class HomesController < ApplicationController
  before_action :find_leagues

  def show; end

  private

  def find_leagues
    @seasons = Season.active.includes(:league).group_by { |season| season.league.sport_kind }
  end
end
