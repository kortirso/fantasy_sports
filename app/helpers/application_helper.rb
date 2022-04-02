# frozen_string_literal: true

module ApplicationHelper
  def change_locale(locale)
    url_for(request.params.merge(locale: locale.to_s))
  end

  def localized_value(value)
    value[I18n.locale.to_s] || value[I18n.default_locale.to_s]
  end

  def react_component(component_name, **props)
    content_tag(
      'div',
      data: {
        react_component: component_name,
        props: props.to_json,
      }
    ) { '' }
  end
end
