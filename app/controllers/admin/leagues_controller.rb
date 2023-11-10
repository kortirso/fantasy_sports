# frozen_string_literal: true

module Admin
  class LeaguesController < AdminController
    include Deps[create_form: 'forms.leagues.create']

    before_action :find_leagues, only: %i[index]

    def index; end

    def new
      @league = League.new
    end

    def create
      case create_form.call(params: league_params)
      in { errors: errors } then redirect_to new_admin_league_path, alert: errors
      else redirect_to admin_leagues_path, notice: t('controllers.admin.leagues.create.success')
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
