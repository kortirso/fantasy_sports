# frozen_string_literal: true

module Admin
  class LeaguesController < AdminController
    before_action :find_league
    before_action :find_active_week

    def show; end

    private

    def find_league
      @league = League.find(params[:id])
    end

    def find_active_week
      @week = @league.active_season.active_week
    end
  end
end
