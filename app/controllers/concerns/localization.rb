# frozen_string_literal: true

module Localization
  extend ActiveSupport::Concern

  included do
    before_action :update_locale
    before_action :set_locale
  end

  private

  def update_locale
    return if params[:locale].blank?
    return if I18n.available_locales.exclude?(params[:locale].to_sym)

    Current.user&.update(locale: params[:locale])
    session[:fantasy_sports_locale] = params[:locale]
  end

  def set_locale
    I18n.locale = Current.user&.locale.presence || session[:fantasy_sports_locale].presence || I18n.default_locale
  end
end
