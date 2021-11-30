# frozen_string_literal: true

module FantasyTeams
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
        leagues_seasons_team = object.teams_player.leagues_seasons_team
        {
          id: leagues_seasons_team.team_id
        }
      end
    end
  end
end
