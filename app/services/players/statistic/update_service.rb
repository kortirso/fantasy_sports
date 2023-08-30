# frozen_string_literal: true

module Players
  module Statistic
    class UpdateService
      # Updates games statistic for players in some season
      prepend ApplicationService

      def call(season_id:, player_ids:)
        @season_id = season_id
        @player_ids = player_ids
        @games_players_statistic = {}

        collect_statistic_of_players
        update_players
      end

      private

      def collect_statistic_of_players
        games_players.each { |games_player| collect_statistic_of_player(games_player) }
      end

      def update_players
        players = @games_players_statistic.map do |player_id, values|
          {
            id: player_id,
            points: values[:points],
            statistic: values[:statistic]
          }
        end
        # commento: players.points, players.statistic
        Player.upsert_all(players) if players.any?
      end

      def collect_statistic_of_player(games_player)
        player_id = games_player.teams_player.player_id

        if @games_players_statistic.key?(player_id)
          @games_players_statistic[player_id]
            .deep_merge!(games_player_hash(games_player)) { |_k, a_value, b_value|
              a_value + b_value
            }
        else
          @games_players_statistic[player_id] = games_player_hash(games_player)
        end
      end

      def games_players
        Games::Player
          .includes(:teams_player, game: :week)
          .where(weeks: { season_id: @season_id })
          .where(teams_player: { player_id: @player_ids })
      end

      def games_player_hash(games_player)
        {
          points: games_player.points.to_d,
          statistic: games_player.statistic || {}
        }
      end
    end
  end
end
