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

    attribute :team do |object, params|
      season_team_id = object.teams_player.seasons_team.id
      fields = { id: object.teams_player.seasons_team.team_id }

      if params_with_field?(params, 'opposite_teams')
        opposite_team_ids =
          object
          .teams_player
          .seasons_team
          .games
          .where(week_id: params[:week_id])
          .map { |e| e.opposite_team_id(season_team_id) }
          .compact
        fields.merge!(opposite_team_ids: opposite_team_ids)
      end

      fields
    end
  end
end
