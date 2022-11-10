# frozen_string_literal: true

module Admin
  class SeasonsController < AdminController
    before_action :find_leagues, only: %i[index new]

    def index; end

    def new
      @season = Season.new
    end

    def create
      service_call = Seasons::CreateService.call(params: season_params)
      if service_call.success?
        redirect_to admin_seasons_path, notice: t('controllers.admin.seasons.create.success')
      else
        redirect_to new_admin_season_path, alert: service_call.errors
      end
    end

    private

    def find_leagues
      @leagues = League.all
    end

    def season_params
      params
        .require(:season)
        .permit(:name, :league_id)
        .to_h
        .symbolize_keys
        .merge(active: params[:season][:active] == '1')
    end
  end
end
