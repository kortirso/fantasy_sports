# frozen_string_literal: true

module Games
  module Players
    class CreateForGameService
      def call(game:)
        games_players = [game.home_season_team, game.visitor_season_team].flat_map do |season_team|
          season_team
            .active_teams_players
            .includes(:player)
            .hashable_pluck(:id, 'players.position_kind').map do |teams_player|
              {
                game_id: game.id,
                teams_player_id: teams_player[:id],
                position_kind: teams_player[:players_position_kind],
                seasons_team_id: season_team.id
              }
            end
        end
        Games::Player.upsert_all(games_players) if games_players.any?
      end
    end
  end
end
