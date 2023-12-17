# frozen_string_literal: true

module Players
  module Seasons
    class RefreshSelectedService
      def call(season_id:)
        fantasy_teams_count = FantasyTeam.where(season_id: season_id).completed.count
        statistic_by_player_id = find_statistic_by_player_id(season_id)

        objects =
          Players::Season
            .where(season_id: season_id)
            .hashable_pluck(:id, :uuid, :player_id).map do |players_season|
              {
                id: players_season[:id],
                uuid: players_season[:uuid],
                player_id: players_season[:player_id],
                season_id: season_id,
                selected_by_teams_ratio: find_ratio(statistic_by_player_id, players_season, fantasy_teams_count)
              }
            end
        # commento: players_seasons.selected_by_teams_ratio
        Players::Season.upsert_all(objects) if objects.any?
      end

      private

      # returns { 1 => 35, 2 => 47 }
      def find_statistic_by_player_id(season_id)
        FantasyTeams::Player
          .joins(teams_player: :players_season)
          .where(teams_players: { active: true })
          .where(players_seasons: { season_id: season_id })
          .group('players_seasons.id')
          .count
      end

      def find_ratio(statistic_by_player_id, players_season, fantasy_teams_count)
        return 0 if fantasy_teams_count.zero?

        (100.0 * statistic_by_player_id[players_season[:id]].to_i / fantasy_teams_count).round
      end
    end
  end
end
