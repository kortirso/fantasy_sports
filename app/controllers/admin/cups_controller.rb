# frozen_string_literal: true

module Admin
  class CupsController < Admin::BaseController
    include Deps[
      create_form: 'forms.cups.create',
      to_bool: 'to_bool'
    ]

    before_action :find_cups, only: %i[index]
    before_action :find_leagues, only: %i[new]

    def index; end

    def new
      @cup = Cup.new
    end

    def create
      case create_form.call(params: cup_params)
      in { errors: errors } then redirect_to new_admin_cup_path, alert: errors
      else redirect_to admin_cups_path, notice: t('controllers.admin.cups.create.success')
      end
    end

    private

    def find_cups
      @cups =
        Cup.joins(:league)
          .order(id: :desc)
          .hashable_pluck(:id, :name, :active, 'leagues.name')
          .group_by { |cup| cup[:leagues_name] }
    end

    def find_leagues
      @leagues = League.all
    end

    def cup_params
      params
        .require(:cup)
        .permit(:league_id)
        .to_h
        .symbolize_keys
        .merge(
          active: to_bool.call(params[:cup][:active]),
          name: { en: params[:cup][:name_en], ru: params[:cup][:name_ru] }
        )
    end
  end
end
