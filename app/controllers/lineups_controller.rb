# frozen_string_literal: true

class LineupsController < ApplicationController
  before_action :find_lineup, only: %i[show]
  before_action :find_lineup_for_update, only: %i[update]

  def show
    render json: { lineup: LineupSerializer.new(@lineup).serializable_hash }, status: :ok
  end

  def update
    service_call = Lineups::UpdateService.call(
      lineup: @lineup,
      params: schema_params(params: params, schema: LineupSchema, required: :lineup)
    )
    if service_call.success?
      render json: { message: t('controllers.lineups.update.success') }, status: :ok
    else
      json_response_with_errors(service_call.errors, 422)
    end
  end

  private

  def find_lineup
    @lineup = Current.user.lineups.find_by!(uuid: params[:id])
  end

  def find_lineup_for_update
    @lineup = Current.user.lineups.joins(:week).where(weeks: { status: Week::COMING }).find_by!(uuid: params[:id])
  end
end
