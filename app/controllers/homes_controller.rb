# frozen_string_literal: true

class HomesController < ApplicationController
  before_action :find_leagues

  def show; end

  private

  def find_leagues
    @leagues = League.all.includes(:active_season).group_by(&:sport_kind)
  end
end
