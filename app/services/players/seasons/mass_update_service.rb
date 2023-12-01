# frozen_string_literal: true

module Players
  module Seasons
    class MassUpdateService
      # Updates games statistic for players in some season
      prepend ApplicationService

      # rubocop: disable Metrics/AbcSize
      def call(season_id:, player_ids:)
        @season_id = season_id
        @player_ids = player_ids
        @week_ids_for_form = Week.active.find_by(season_id: season_id).weeks_ids_for_form_calculation

        objects =
          Players::Season
            .where(season_id: season_id, player_id: player_ids)
            .hashable_pluck(:id, :uuid, :player_id).map do |players_season|
              {
                id: players_season[:id],
                uuid: players_season[:uuid],
                points: statistic_by_player_id.dig(players_season[:player_id], :points),
                average_points: average_points(players_season[:player_id]),
                form: form(players_season[:player_id]),
                statistic: statistic_by_player_id.dig(players_season[:player_id], :statistic),
                player_id: players_season[:player_id],
                season_id: season_id
              }
            end
        # commento: players_seasons.points, players_seasons.statistic
        # commento: players_seasons.average_points, players_seasons.form
        Players::Season.upsert_all(objects) if objects.any?
      end

      private

      # returns { 1 => { points: 0.0, statistic: {} } }
      def statistic_by_player_id
        @statistic_by_player_id ||=
          Games::Player
            .includes(:teams_player, game: :week)
            .where(weeks: { season_id: @season_id })
            .where(teams_player: { player_id: @player_ids })
            .hashable_pluck(:points, :statistic, 'teams_player.player_id', 'weeks.id')
            .group_by { |e| e[:teams_player_player_id] }
            .transform_values do |games_players|
              games_players.each_with_object(default_statistic) do |games_player, acc|
                if @week_ids_for_form.include?(games_player[:weeks_id])
                  acc[:form_points] += games_player[:points].to_f.round(1)
                  acc[:form_games] += 1
                end
                acc[:points] += games_player[:points].to_f.round(1)
                acc[:played_games] += 1 if games_player.dig(:statistic, 'MP').to_i.positive?
                acc[:statistic].deep_merge!(games_player[:statistic]) { |_k, a_value, b_value|
                  a_value + b_value
                }
              end
            end
      end
      # rubocop: enable Metrics/AbcSize

      def default_statistic
        { points: 0, statistic: {}, played_games: 0, form_points: 0, form_games: 0 }
      end

      def average_points(player_id)
        played_games = statistic_by_player_id.dig(player_id, :played_games)
        played_games.zero? ? 0 : (statistic_by_player_id.dig(player_id, :points).to_f / played_games).round(1)
      end

      def form(player_id)
        form_games = statistic_by_player_id.dig(player_id, :form_games)
        form_games.zero? ? 0 : (statistic_by_player_id.dig(player_id, :form_points).to_f / form_games).round(1)
      end
    end
  end
end
