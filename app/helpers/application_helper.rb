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
      id: props[:component_id],
      class: props[:component_class],
      data: {
        react_component: component_name,
        props: props.except(:component_id, :component_class, :children).to_json,
        children: props[:children]&.to_json
      }
    ) { '' }
  end

  def league_background(league_name)
    case league_name
    when 'English Premier League', 'Premier League' then 'leagues/epl.webp'
    when 'Russian Premier League' then 'leagues/rpl.webp'
    when 'Seria A' then 'leagues/seria_a.webp'
    when 'La Liga' then 'leagues/la_liga.webp'
    when 'NBA' then 'leagues/nba.webp'
    end
  end
end
