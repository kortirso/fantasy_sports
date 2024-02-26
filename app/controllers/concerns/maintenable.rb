# frozen_string_literal: true

module Maintenable
  extend ActiveSupport::Concern

  private

  def check_season_maintenance
    return if @season.nil? || !@season.maintenance?

    flash[:warning] = t('controllers.maintenable.maintenance')
  end

  # rubocop: disable Metrics/CyclomaticComplexity
  def validate_season_maintenance
    return unless @fantasy_team&.season&.maintenance? || @lineup&.week&.season&.maintenance?

    json_response_with_errors([t('controllers.maintenable.maintenance')], 422)
  end
  # rubocop: enable Metrics/CyclomaticComplexity
end
