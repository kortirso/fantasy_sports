# frozen_string_literal: true

module ApplicationHelper
  def change_locale(locale)
    url_for(request.params.merge(locale: locale.to_s))
  end

  def localized_value(value)
    value[I18n.locale.to_s] || value[I18n.default_locale.to_s]
  end
end
