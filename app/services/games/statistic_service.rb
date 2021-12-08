# frozen_string_literal: true

module Games
  class StatisticService
    prepend ApplicationService

    def initialize(
      player_statistic_update_service:   Games::Players::Statistic::UpdateService,
      lineups_players_update_points_job: Lineups::Players::UpdatePointsJob
    )
      @player_statistic_update_service   = player_statistic_update_service
      @lineups_players_update_points_job = lineups_players_update_points_job
    end

    def call(game:, games_players_statistic:)
      @game                    = game
      @games_players_statistic = games_players_statistic
      @games_players           = Games::Player.where(id: games_players_statistic.keys.map(&:to_i))
      @teams_players_points    = {}

      update_games_players_statistic
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

    def update_lineups_players_points
      @lineups_players_update_points_job.perform_now(
        teams_players_points: @teams_players_points.to_json,
        week_id:              @game.week_id
      )
    end
  end
end
