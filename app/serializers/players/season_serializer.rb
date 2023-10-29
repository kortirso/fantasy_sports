# frozen_string_literal: true

module Players
  class SeasonSerializer < ApplicationSerializer
    attributes :uuid, :form, :points, :average_points

    attribute :player do |object|
      player = object.player
      {
        name: player.name,
        position_kind: player.position_kind
      }
    end

    attribute :team do |object|
      team = object.active_teams_player&.seasons_team&.team
      {
        uuid: team&.uuid,
        name: team&.name,
        price: object.active_teams_player&.price_cents.to_i / 100.0
      }
    end
  end
end
