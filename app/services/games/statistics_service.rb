# frozen_string_literal: true

module Games
  class StatisticsService
    prepend ApplicationService

    def call(game:)
      @game = game
      @result = rendered_sport_stats.map do |sport_stat|
        {
          key: sport_stat,
          home_team: get_players_with_stats(home_games_players, sport_stat),
          visitor_team: get_players_with_stats(visitor_games_players, sport_stat)
        }
      end
    end

    private

    def get_players_with_stats(games_players, sport_stat)
      games_players.sort_by { |e| -e.statistic[sport_stat].to_i }.filter_map { |game_player|
        next if game_player.statistic[sport_stat].to_i.zero?

        [
          game_player.teams_player.player.shirt_name,
          game_player.statistic[sport_stat]
        ]
      }
    end

    def rendered_sport_stats
      Statable::RENDERED_SPORT_STATS[@game.week.season.league.sport_kind]
    end

    def home_games_players
      @home_games_players ||=
        @game
        .games_players
        .includes(teams_player: :player)
        .where(teams_player: { seasons_team_id: @game.home_season_team_id, active: true })
    end

    def visitor_games_players
      @visitor_games_players ||=
        @game
        .games_players
        .includes(teams_player: :player)
        .where(teams_player: { seasons_team_id: @game.visitor_season_team_id, active: true })
    end
  end
end
