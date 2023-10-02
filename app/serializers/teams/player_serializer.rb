# frozen_string_literal: true

module Teams
  class PlayerSerializer < ApplicationSerializer
    attributes :uuid, :form

    attribute :price do |object|
      object.price_cents / 100.0
    end

    attribute :player do |object|
      player = object.player
      {
        name: player.name,
        position_kind: player.position_kind,
        points: player.points,
        statistic: player.statistic
      }
    end

    attribute :team do |object|
      team = object.seasons_team.team
      {
        uuid: team.uuid,
        name: team.name
      }
    end
  end
end
