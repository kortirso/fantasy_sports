# frozen_string_literal: true

module Teams
  class PlayerSerializer < ApplicationSerializer
    attributes :id

    attribute :price do |object|
      object.price_cents / 100.0
    end

    attribute :player do |object, params|
      player = object.player
      fields = { name: player.name, position_kind: player.position_kind }

      if params_with_field?(params, 'season_statistic')
        fields[:points] = player.points
        fields[:statistic] = player.statistic
      end

      fields
    end

    attribute :team do |object|
      seasons_team = object.seasons_team
      {
        id: seasons_team.team_id
      }
    end
  end
end
