# frozen_string_literal: true

module Games
  class StatisticService
    prepend ApplicationService

    def initialize(
      player_statistic_update_service:   Games::Players::Statistic::UpdateService,
      lineups_players_points_update_job: Lineups::Players::Points::UpdateJob,
      players_statistic_update_job:      Players::Statistic::UpdateJob
    )
      @player_statistic_update_service   = player_statistic_update_service
      @lineups_players_points_update_job = lineups_players_points_update_job
      @players_seasons_update_job        = players_statistic_update_job
    end

    def call(game:, games_players_statistic:)
      @game                    = game
      @games_players_statistic = games_players_statistic
      @games_players           = Games::Player.where(id: games_players_statistic.keys.map(&:to_i))
      @teams_players_points    = {}

      update_games_players_statistic
      update_players_seasons_statistic
      update_lineups_players_points
    end

    private

    def update_games_players_statistic
      @games_players.each do |games_player|
        statistic = @games_players_statistic[games_player.id.to_s].transform_values(&:to_i)
        points    = @player_statistic_update_service.call(games_player: games_player, statistic: statistic).result
        @teams_players_points[games_player.teams_player_id] = points
      end
    end

    def update_players_seasons_statistic
      player_ids = @games_players.map { |games_player| games_player.teams_player.player_id }
      @players_statistic_update_job.perform_now(season_id: @game.week.season_id, player_ids: player_ids)
    end

    def update_lineups_players_points
      @lineups_players_points_update_job.perform_now(
        teams_players_points: @teams_players_points.to_json,
        week_id:              @game.week_id
      )
    end
  end
end
