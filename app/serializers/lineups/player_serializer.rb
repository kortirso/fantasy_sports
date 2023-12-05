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

    attribute :player do |object, params|
      player = object.teams_player.player
      injuries = params[:injuries][object.teams_player.players_season_id]
      {
        uuid: object.teams_player.players_season.uuid,
        name: player.name,
        shirt_name: player.shirt_name,
        position_kind: player.position_kind,
        injury: injuries.blank? ? nil : InjurySerializer.new(injuries[0]).serializable_hash
      }
    end

    attribute :team do |object|
      seasons_team = object.teams_player.seasons_team
      {
        uuid: seasons_team.team.uuid
      }
    end

    attribute :week_statistic, if: proc { |_, params| params[:games_players].present? } do |object, params|
      games_players = params[:games_players][object.teams_player_id]

      games_players.each_with_object({}) do |games_player, acc|
        acc.deep_merge!(games_player[:statistic]) { |_k, a_value, b_value|
          a_value + b_value
        }
      end
    end
  end
end
