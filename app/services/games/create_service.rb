# frozen_string_literal: true

module Games
  class CreateService
    prepend ApplicationService

    def call(attributes)
      create_game(attributes)
      create_games_players(attributes[:home_season_team], attributes[:visitor_season_team])
    end

    private

    def create_game(attributes)
      @result = ::Game.create attributes
    end

    def create_games_players(home_season_team, visitor_season_team)
      [home_season_team, visitor_season_team].each do |season_team|
        season_team.active_teams_players.includes(:player).each do |teams_player|
          @result.games_players.create(teams_player: teams_player, position_kind: teams_player.player.position_kind)
        end
      end
    end
  end
end
