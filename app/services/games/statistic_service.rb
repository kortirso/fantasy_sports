# frozen_string_literal: true

module Games
  class StatisticService
    prepend ApplicationService

    def initialize(
      player_statistic_update_service: Games::Players::Statistic::UpdateService
    )
      @player_statistic_update_service = player_statistic_update_service
    end

    def call(game:, games_players_statistic:)
      @game                    = game
      @games_players_statistic = games_players_statistic
      @games_players           = Games::Player.where(id: games_players_statistic.keys.map(&:to_i))
      @teams_players_points    = {}

      update_games_players_statistic
      update_lineups_players_points
      update_lineups_points
    end

    private

    def update_games_players_statistic
      @games_players.each do |games_player|
        statistic = @games_players_statistic[games_player.id.to_s].transform_values(&:to_i)
        points = @player_statistic_update_service.call(games_player: games_player, statistic: statistic).result

        @teams_players_points[games_player.teams_player_id] = points
      end
    end

    # TODO: move to background job
    def update_lineups_players_points
      @lineups_players =
        Lineups::Player.joins(lineup: :week)
        .where(teams_player_id: Teams::Player.where(id: @teams_players_points.keys))
        .where(weeks: { id: @game.week_id })

      @lineups_players.each do |lineups_player|
        lineups_player.update(points: @teams_players_points[lineups_player.teams_player_id])
      end
    end

    # TODO: move to background job
    # TODO: add calculating points for lineups
    def update_lineups_points
      lineups = Lineup.where(id: @lineups_players.pluck(:lineup_id))
    end
  end
end
