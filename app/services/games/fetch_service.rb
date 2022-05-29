# frozen_string_literal: true

module Games
  class FetchService
    prepend ApplicationService

    def initialize(
      player_statistic_update_service: ::Games::Players::Statistic::UpdateService,
      fetch_service:                   ::Import::FetchService,
      form_change_service:             Teams::Players::Form::ChangeService
    )
      @player_statistic_update_service = player_statistic_update_service
      @fetch_service                   = fetch_service
      @form_change_service             = form_change_service
    end

    def call(game:)
      @game = game

      game_data = fetch_game_data
      update_players(@game.home_season_team_id, game_data[0])
      update_players(@game.visitor_season_team_id, game_data[1])
      update_players_form

      # TODO
      # add here other calculation for lineups and teams from StatisticService
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

    def update_players_form
      @form_change_service.call(
        games_ids:         Game.where(week_id: @game.week.weeks_ids_for_form_calculation).order(id: :asc).ids,
        seasons_teams_ids: [@game.home_season_team_id, @game.visitor_season_team_id]
      )
    end
  end
end
