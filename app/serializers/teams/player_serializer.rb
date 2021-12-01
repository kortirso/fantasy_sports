# frozen_string_literal: true

module Teams
  class PlayerSerializer < ApplicationSerializer
    attributes :id

    attribute :price do |object|
      object.price_cents / 100.0
    end

    attribute :player do |object|
      player = object.player
      {
        name:               player.name,
        sports_position_id: player.sports_position_id
      }
    end

    attribute :team do |object|
      seasons_team = object.seasons_team
      {
        id: seasons_team.team_id
      }
    end
  end
end
