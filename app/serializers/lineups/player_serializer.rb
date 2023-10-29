# frozen_string_literal: true

module Lineups
  class PlayerSerializer < ApplicationSerializer
    attributes :uuid, :change_order, :status

    attribute :active, &:active?

    attribute :points do |object|
      object.points.presence || '-'
    end

    attribute :teams_player do |object|
      {
        uuid: object.teams_player.uuid,
        shirt_number: object.teams_player.shirt_number_string
      }
    end

    attribute :player do |object|
      player = object.teams_player.player
      {
        uuid: object.teams_player.players_season.uuid,
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
