# frozen_string_literal: true

class GameSerializer < ApplicationSerializer
  attributes :uuid, :points, :start_at

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
