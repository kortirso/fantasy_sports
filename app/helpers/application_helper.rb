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
    when 'Bundesliga' then 'leagues/bundesliga.webp'
    when 'NBA' then 'leagues/nba.webp'
    end
  end

  def omniauth_link(provider)
    case provider
    when :google then google_oauth_link
    end
  end

  private

  # rubocop: disable Layout/LineLength
  def google_oauth_link
    "https://accounts.google.com/o/oauth2/auth?scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email&response_type=code&client_id=#{value(:google_oauth, :client_id)}&redirect_uri=#{value(:google_oauth, :redirect_url)}"
  end
  # rubocop: enable Layout/LineLength

  def value(provider_oauth, key)
    Rails.application.credentials.dig(provider_oauth, Rails.env.to_sym, key)
  end
end
