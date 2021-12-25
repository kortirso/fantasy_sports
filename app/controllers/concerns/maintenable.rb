# frozen_string_literal: true

module Maintenable
  extend ActiveSupport::Concern

  private

  def check_league_maintenance
    return if @season.nil? || !@season.league.maintenance?

    flash[:warning] = t('controllers.maintenable.maintenance')
  end

  def validate_league_maintenance
    return unless @league.maintenance?

    json_response_with_errors([t('controllers.maintenable.maintenance')], 422)
  end
end
