# frozen_string_literal: true

module Lineups
  class PlayerSerializer < ApplicationSerializer
    attributes :id, :active, :change_order, :teams_player_id

    attribute :points do |object|
      object.points.presence || '-'
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
        id: seasons_team.team_id
      }
    end
  end
end
