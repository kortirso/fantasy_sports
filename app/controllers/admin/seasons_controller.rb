# frozen_string_literal: true

module Admin
  class SeasonsController < AdminController
    include Boolable

    before_action :find_leagues, only: %i[index new]

    def index; end

    def new
      @season = Season.new
    end

    def create
      form = ::Seasons::CreateForm.call(params: season_params)
      if form.success?
        redirect_to admin_seasons_path, notice: t('controllers.admin.seasons.create.success')
      else
        redirect_to new_admin_season_path, alert: form.errors
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
        .merge(active: to_bool(params[:season][:active]))
    end
  end
end
