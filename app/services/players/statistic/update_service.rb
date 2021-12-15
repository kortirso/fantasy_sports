# frozen_string_literal: true

module Players
  module Statistic
    class UpdateService
      prepend ApplicationService

      def call(season_id:, player_ids:)
        @season_id = season_id
        @player_ids = player_ids

        collect_statistic_of_players
        update_players_seasons
      end

      private

      def collect_statistic_of_players
        @game_players_statistic = {}
        games_player.each { |game_player| collect_statistic_of_player(game_player) }
      end

      def update_players_seasons
        @game_players_statistic.each do |player_id, values|
          Player.find(player_id).update(
            points:    values[:points],
            statistic: values[:statistic]
          )
        end
      end

      def collect_statistic_of_player(game_player)
        player_id = game_player.teams_player.player_id

        if @game_players_statistic.key?(player_id)
          @game_players_statistic[player_id]
            .deep_merge(game_player_hash(game_player)) { |_k, a_value, b_value|
              a_value + b_value
            }
        else
          @game_players_statistic[player_id] = game_player_hash(game_player)
        end
      end

      def games_player
        Games::Player
          .joins(game: :week)
          .includes(teams_player: :player)
          .where(weeks: { season_id: @season_id })
          .where(players: { id: @player_ids })
      end

      def game_player_hash(game_player)
        {
          points:    game_player.points.to_i,
          statistic: game_player.statistic || {}
        }
      end
    end
  end
end
