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
    switch_locale = params[:switch_locale]
    return if switch_locale.blank?
    return if I18n.available_locales.exclude?(switch_locale.to_sym)

    Current.user&.update(locale: switch_locale)
    cookies.permanent[:fantasy_sports_locale] = switch_locale
  end
  # rubocop: enable Metrics/AbcSize

  def set_locale
    locale = params[:locale]&.to_sym
    I18n.locale =
      if I18n.available_locales.include?(locale) && I18n.default_locale != locale
        locale
      else
        Current.user&.locale.presence || cookies[:fantasy_sports_locale].presence || I18n.default_locale
      end
  end
end
