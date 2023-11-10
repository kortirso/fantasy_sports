# frozen_string_literal: true

class LineupsController < ApplicationController
  include Deps[update_form: 'forms.lineups.update']

  before_action :find_lineup, only: %i[show]
  before_action :find_lineup_for_update, only: %i[update]

  def show
    render json: { lineup: lineup }, status: :ok
  end

  def update
    form = update_form.call(
      lineup: @lineup,
      params: schema_params(params: params, schema: LineupSchema, required: :lineup)
    )
    case form
    in { errors: errors } then json_response_with_errors(errors, 422)
    else render json: { message: t('controllers.lineups.update.success') }, status: :ok
    end
  end

  private

  def find_lineup
    @lineup = Current.user.lineups.find_by!(uuid: params[:id])
  end

  def find_lineup_for_update
    @lineup = Current.user.lineups.joins(:week).where(weeks: { status: Week::COMING }).find_by!(uuid: params[:id])
  end

  def lineup
    Rails.cache.fetch(
      ['lineups_show_v1', @lineup.id, @lineup.updated_at],
      expires_in: 12.hours,
      race_condition_ttl: 10.seconds
    ) do
      LineupSerializer.new(@lineup).serializable_hash
    end
  end
end
