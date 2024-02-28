# frozen_string_literal: true

class GameSerializer < ApplicationSerializer
  attributes :uuid, :points, :start_at

  attribute :predictable, &:predictable?

  attribute :home_team do |object|
    team = object.home_season_team.team
    {
      uuid: team.uuid,
      name: team.name
    }
  end

  attribute :visitor_team do |object|
    team = object.visitor_season_team.team
    {
      uuid: team.uuid,
      name: team.name
    }
  end
end
