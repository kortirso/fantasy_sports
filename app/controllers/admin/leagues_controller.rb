# frozen_string_literal: true

module Admin
  class LeaguesController < AdminController
    before_action :find_leagues, only: %i[index]

    def index; end

    def new
      @league = League.new
    end

    def create
      validator_errors = LeagueValidator.call(params: league_params)
      if validator_errors.empty?
        League.create(league_params)
        redirect_to admin_leagues_path, notice: t('controllers.admin.leagues.create.success')
      else
        redirect_to new_admin_league_path, alert: validator_errors
      end
    end

    private

    def find_leagues
      @leagues = League.all
    end

    def league_params
      params
        .require(:league)
        .permit(:sport_kind)
        .to_h
        .merge(name: { en: params[:league][:name_en], ru: params[:league][:name_ru] })
    end
  end
end
