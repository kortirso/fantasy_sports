# frozen_string_literal: true

module Players
  module Statistic
    class UpdateService
      # Updates games statistic for players in some season
      prepend ApplicationService

      def call(season_id:, player_ids:)
        @season_id = season_id
        @player_ids = player_ids

        collect_statistic_of_players
        update_players_seasons
      end

      private

      def collect_statistic_of_players
        @games_players_statistic = {}
        games_players.each { |games_player| collect_statistic_of_player(games_player) }
      end

      def update_players_seasons
        @games_players_statistic.each do |player_id, values|
          Player.find(player_id).update(
            points:    values[:points],
            statistic: values[:statistic]
          )
        end
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
          .joins(:teams_player, game: :week)
          .where(weeks: { season_id: @season_id })
          .where(teams_player: { player_id: @player_ids })
      end

      def games_player_hash(games_player)
        {
          points:    games_player.points.to_i,
          statistic: games_player.statistic || {}
        }
      end
    end
  end
end
