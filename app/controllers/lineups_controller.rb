# frozen_string_literal: true

class LineupsController < ApplicationController
  before_action :find_lineup

  def show
    render json: { lineup: LineupSerializer.new(@lineup).serializable_hash }, status: :ok
  end

  def update
    service_call = Lineups::UpdateService.call(lineup: @lineup, params: lineup_params)
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

  def lineup_params
    params.require(:lineup).permit(active_chips: [])
  end
end
