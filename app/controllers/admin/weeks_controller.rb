# frozen_string_literal: true

module Admin
  class WeeksController < Admin::BaseController
    include Deps[update_form: 'forms.weeks.update']

    before_action :find_weeks, only: %i[index]
    before_action :find_week, only: %i[edit update]

    def index; end

    def edit; end

    def update
      case update_form.call(week: @week, params: week_update_params.to_h.symbolize_keys)
      in { errors: errors } then redirect_to edit_admin_week_path(@week.id), alert: errors
      else
        redirect_to admin_weeks_path(season_id: @week.season_id), notice: t('controllers.admin.weeks.update.success')
      end
    end

    private

    def find_weeks
      @weeks = Season.find(params[:season_id]).weeks.order(position: :asc)
    end

    def find_week
      @week = Week.find(params[:id])
    end

    def week_update_params
      deadline_at = params.dig(:week, :deadline_at)
      {
        deadline_at: deadline_at.present? ? DateTime.parse(deadline_at) : @week.deadline_at
      }
    end
  end
end
