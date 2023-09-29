# frozen_string_literal: true

module Admin
  class LeaguesController < AdminController
    before_action :find_leagues, only: %i[index]

    def index; end

    def new
      @league = League.new
    end

    def create
      form = ::Leagues::CreateForm.call(params: league_params)
      if form.success?
        redirect_to admin_leagues_path, notice: t('controllers.admin.leagues.create.success')
      else
        redirect_to new_admin_league_path, alert: form.errors
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
