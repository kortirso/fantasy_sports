# frozen_string_literal: true

class GameSerializer < ApplicationSerializer
  attributes :uuid

  attribute :date_start_at do |object|
    object.start_at.strftime('%d.%m.%Y')
  end

  attribute :time_start_at do |object|
    object.start_at.strftime('%H:%M')
  end

  attribute :home_team do |object|
    seasons_team = object.home_season_team
    {
      uuid: seasons_team.team.uuid
    }
  end

  attribute :visitor_team do |object|
    seasons_team = object.visitor_season_team
    {
      uuid: seasons_team.team.uuid
    }
  end
end
