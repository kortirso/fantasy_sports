# frozen_string_literal: true

module Games
  class CreateService
    prepend ApplicationService

    def call(week:, home_season_team:, visitor_season_team:)
      create_game(week, home_season_team, visitor_season_team)
      create_games_players(home_season_team, visitor_season_team)
    end

    private

    def create_game(week, home_season_team, visitor_season_team)
      @result = week.games.create home_season_team: home_season_team, visitor_season_team: visitor_season_team
    end

    def create_games_players(home_season_team, visitor_season_team)
      [home_season_team, visitor_season_team].each do |season_team|
        season_team.active_teams_players.each do |teams_player|
          @result.games_players.create(teams_player: teams_player)
        end
      end
    end
  end
end
