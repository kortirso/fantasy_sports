# frozen_string_literal: true

module Lineups
  class PlayerSerializer < ApplicationSerializer
    attributes :id, :active, :change_order

    attribute :player do |object|
      player = object.teams_player.player
      {
        name:               player.name,
        sports_position_id: player.sports_position_id
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
