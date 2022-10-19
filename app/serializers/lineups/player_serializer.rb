# frozen_string_literal: true

module Lineups
  class PlayerSerializer < ApplicationSerializer
    attributes :uuid, :active, :change_order, :status

    attribute :points do |object|
      object.points.presence || '-'
    end

    attribute :teams_player do |object|
      {
        uuid: object.teams_player.uuid
      }
    end

    attribute :player do |object|
      player = object.teams_player.player
      {
        name: player.name,
        position_kind: player.position_kind
      }
    end

    attribute :team do |object|
      seasons_team = object.teams_player.seasons_team
      {
        uuid: seasons_team.team.uuid
      }
    end
  end
end
