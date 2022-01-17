# frozen_string_literal: true

module Games
  class FetchService
    prepend ApplicationService

    def initialize(
      player_statistic_update_service: ::Games::Players::Statistic::UpdateService,
      fetch_service:                   ::Import::FetchService
    )
      @player_statistic_update_service = player_statistic_update_service
      @fetch_service                   = fetch_service
    end

    def call(game:)
      @game = game

      game_data = fetch_game_data
      update_players(@game.home_season_team_id, game_data[0])
      update_players(@game.visitor_season_team_id, game_data[1])
    end

    private

    def fetch_game_data
      @fetch_service.call(
        source:      @game.source,
        external_id: @game.external_id,
        sport_kind:  @game.week.league.sport_kind
      ).result
    end

    def update_players(season_team_id, game_data)
      games_players =
        @game
        .games_players
        .includes(:teams_player)
        .where(teams_player: { seasons_team_id: season_team_id, active: true, shirt_number: game_data.keys })
      games_players.each do |games_player|
        statistic = game_data[games_player.teams_player.shirt_number]
        @player_statistic_update_service.call(games_player: games_player, statistic: statistic)
      end
    end
  end
end
