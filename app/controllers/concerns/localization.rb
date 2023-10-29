# frozen_string_literal: true

module Localization
  extend ActiveSupport::Concern

  included do
    before_action :update_locale
    before_action :set_locale
  end

  private

  # rubocop: disable Metrics/AbcSize
  def update_locale
    return if params[:locale].blank?
    return if I18n.available_locales.exclude?(params[:locale].to_sym)

    Current.user&.update(locale: params[:locale])
    cookies.permanent[:fantasy_sports_locale] = params[:locale]
  end
  # rubocop: enable Metrics/AbcSize

  def set_locale
    I18n.locale = Current.user&.locale.presence || cookies[:fantasy_sports_locale].presence || I18n.default_locale
  end
end
