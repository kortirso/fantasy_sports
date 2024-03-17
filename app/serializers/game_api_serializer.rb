# frozen_string_literal: true

class GameApiSerializer < ApplicationSerializer
  set_id :id

  attribute :id, if: proc { |_, params| required_field?(params, 'id') }, &:id
  attribute :points, if: proc { |_, params| required_field?(params, 'points') }, &:points
  attribute :start_at, if: proc { |_, params| required_field?(params, 'start_at') }, &:start_at
  attribute :predictable, if: proc { |_, params| required_field?(params, 'predictable') }, &:predictable?

  attribute :home_team, if: proc { |_, params| required_field?(params, 'home_team') } do |object|
    team = object.home_season_team.team
    {
      id: team.id,
      name: team.name[I18n.locale.to_s]
    }
  end

  attribute :visitor_team, if: proc { |_, params| required_field?(params, 'visitor_team') } do |object|
    team = object.visitor_season_team.team
    {
      id: team.id,
      name: team.name[I18n.locale.to_s]
    }
  end
end
