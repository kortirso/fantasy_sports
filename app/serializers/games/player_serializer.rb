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

    attribute :team do |object|
      game = object.game
      player_of_home_team = object.seasons_team_id == game.home_season_team_id
      {
        is_home_game: player_of_home_team,
        points: game.points,
        game_result: game.result_for_team(player_of_home_team ? 0 : 1)
      }
    end

    attribute :opponent_team do |object|
      game = object.game
      player_of_home_team = object.seasons_team_id == game.home_season_team_id
      {
        uuid: player_of_home_team ? game.visitor_season_team.team.uuid : game.home_season_team.team.uuid
      }
    end
  end
end
