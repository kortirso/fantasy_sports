# frozen_string_literal: true

module Admin
  class SeasonsController < Admin::BaseController
    include Deps[
      create_form: 'forms.seasons.create',
      to_bool: 'to_bool'
    ]

    before_action :find_seasons, only: %i[index]
    before_action :find_leagues, only: %i[new]

    def index; end

    def new
      @season = Season.new
    end

    def create
      # commento: seasons.name, seasons.status
      case create_form.call(params: season_params)
      in { errors: errors } then redirect_to new_admin_season_path, alert: errors
      else redirect_to admin_seasons_path, notice: t('controllers.admin.seasons.create.success')
      end
    end

    private

    def find_seasons
      @seasons =
        Season.joins(:league)
          .order(id: :desc)
          .hashable_pluck(:id, :uuid, :name, :status, 'leagues.name')
          .group_by { |season| season[:leagues_name] }
    end

    def find_leagues
      @leagues = League.all
    end

    def season_params
      params.require(:season).permit(:name, :league_id, :status)
    end
  end
end
