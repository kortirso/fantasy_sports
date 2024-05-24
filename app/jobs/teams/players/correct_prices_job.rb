# frozen_string_literal: true

module Teams
  module Players
    class CorrectPricesJob < ApplicationJob
      queue_as :default

      ALLOWED_LEAGUES_FOR_CORRECTING = %w[NBA].freeze

      def perform(week_id:)
        @week = Week.find_by(id: week_id)
        return unless @week
        # TODO: add feature flag
        return unless ALLOWED_LEAGUES_FOR_CORRECTING.include?(@week.season.league.name['en'])

        @objects = []
        # players with huge amount of points, but price < 1_500
        update_cheap_players
        # player with price > 1_000, but coefficient < 1.5
        update_lazy_players

        Teams::Player.upsert_all(@objects) if @objects.any?
      end

      private

      def update_cheap_players
        update_top_cheap_players(low_price_players.keys[0..9], 100)
        update_top_cheap_players(low_price_players.keys[10..19], 50)
        update_top_cheap_players(low_price_players.keys[20..29], 20)
      end

      def update_top_cheap_players(ids, price_change)
        best_players(ids).each do |teams_player|
          next unless teams_player
          next if low_price_players[teams_player[:id]].to_f < 3
          next if teams_player[:price_cents] + price_change > 1_500

          @objects << object_for_update(teams_player, teams_player[:price_cents] + price_change)
        end
      end

      def update_lazy_players
        scope
          .where(price_cents: 1_000..)
          .hashable_pluck(:id, :price_cents, :seasons_team_id, :player_id, :players_season_id)
          .each do |teams_player|
            coef = low_price_players[teams_player[:id]].to_f
            next if coef.zero? || coef > 1.5

            @objects << object_for_update(teams_player, teams_player[:price_cents] - 50)
          end
      end

      def best_players(ids)
        scope.where(id: ids).hashable_pluck(:id, :price_cents, :seasons_team_id, :player_id, :players_season_id)
      end

      def object_for_update(teams_player, price)
        {
          id: teams_player[:id],
          seasons_team_id: teams_player[:seasons_team_id],
          player_id: teams_player[:player_id],
          players_season_id: teams_player[:players_season_id],
          price_cents: price
        }
      end

      # rubocop: disable Metrics/AbcSize, Style/MultilineBlockChain
      def low_price_players
        @low_price_players ||=
          scope
            .joins(:players_season)
            .where(price_cents: ...1_500)
            .where.not(players_seasons: { average_points: 0 })
            .hashable_pluck(:id, :price_cents, 'players_seasons.average_points')
            .each_with_object({}) do |teams_player, acc|
              points = 100 * teams_player[:players_seasons_average_points]
              acc[teams_player[:id]] = (points / teams_player[:price_cents]).to_f.round(1)
            end.sort_by { |_, value| -value }.to_h
      end
      # rubocop: enable Metrics/AbcSize, Style/MultilineBlockChain

      def scope
        @week.teams_players.active
      end
    end
  end
end
