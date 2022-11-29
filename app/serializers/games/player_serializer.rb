# frozen_string_literal: true

module Games
  class PlayerSerializer < ApplicationSerializer
    attributes :uuid, :statistic, :points

    attribute :week do |object|
      week = object.game.week
      {
        position: week.position
      }
    end

    attribute :opponent_team do |object|
      game = object.game
      player_of_home_team = object.seasons_team == game.home_season_team
      {
        uuid: player_of_home_team ? game.visitor_season_team.team.uuid : game.home_season_team.team.uuid
      }
    end
  end
end
