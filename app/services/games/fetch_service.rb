# frozen_string_literal: true

module Games
  class FetchService
    prepend ApplicationService

    def initialize(
      player_statistic_update_service:   ::Games::Players::Statistic::UpdateService,
      fetch_service:                     ::Import::FetchService,
      form_change_service:               ::Teams::Players::Form::ChangeService,
      lineups_players_points_update_job: ::Lineups::Players::Points::UpdateJob,
      players_statistic_update_job:      ::Players::Statistic::UpdateJob
    )
      @player_statistic_update_service   = player_statistic_update_service
      @fetch_service                     = fetch_service
      @form_change_service               = form_change_service
      @lineups_players_points_update_job = lineups_players_points_update_job
      @players_statistic_update_job      = players_statistic_update_job
    end

    def call(game:)
      @game = game
      @team_player_ids = []
      @player_ids = []

      update_games_players_statistic
      update_players_statistic
      update_lineups_players_points
    end

    private

    def update_games_players_statistic
      game_data = fetch_game_data
      update_games_players_points(@game.home_season_team_id, game_data[0])
      update_games_players_points(@game.visitor_season_team_id, game_data[1])
      update_games_players_form
    end

    def fetch_game_data
      @fetch_service.call(
        source: @game.source,
        external_id: @game.external_id,
        sport_kind: @game.week.league.sport_kind
      ).result
    end

    def update_games_players_points(season_team_id, game_data)
      games_players =
        @game
        .games_players
        .includes(:teams_player)
        .where(teams_player: { seasons_team_id: season_team_id, active: true, shirt_number: game_data.keys })

      games_players.each do |games_player|
        statistic = game_data[games_player.teams_player.shirt_number]
        @player_statistic_update_service.call(games_player: games_player, statistic: statistic)

        @team_player_ids.push(games_player.teams_player_id)
        @player_ids.push(games_player.teams_player.player_id)
      end
    end

    def update_games_players_form
      @form_change_service.call(
        games_ids: Game.where(week_id: @game.week.weeks_ids_for_form_calculation).order(id: :asc).ids,
        seasons_teams_ids: [@game.home_season_team_id, @game.visitor_season_team_id]
      )
    end

    def update_players_statistic
      @players_statistic_update_job.perform_now(season_id: @game.week.season_id, player_ids: @player_ids)
    end

    def update_lineups_players_points
      @lineups_players_points_update_job.perform_now(
        team_player_ids: @team_player_ids,
        week_id: @game.week_id
      )
    end
  end
end
