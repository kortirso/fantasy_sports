# frozen_string_literal: true

module Lineups
  class PlayerSerializer < ApplicationSerializer
    attributes :id, :active, :change_order

    attribute :points do |object|
      object.points.present? ? object.points : '-'
    end

    attribute :player do |object|
      player = object.teams_player.player
      {
        name:          player.name,
        position_kind: player.position_kind
      }
    end

    attribute :team do |object, params|
      seasons_team = object.teams_player.seasons_team
      fields = { id: seasons_team.team_id }

      if params_with_field?(params, 'opposite_teams')
        seasons_teams_ids =
          Game
          .joins(:games_players)
          .where(week_id: params[:week_id], games_players: { teams_player_id: object.teams_player_id })
          .pluck(:home_season_team_id, :visitor_season_team_id)
          .flatten
          .uniq
        opposite_team_ids = Seasons::Team.where(id: (seasons_teams_ids - [seasons_team.id])).pluck(:team_id)
        fields.merge!(opposite_team_ids: opposite_team_ids)
      end

      fields
    end
  end
end
