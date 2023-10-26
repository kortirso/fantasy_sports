# frozen_string_literal: true

module Teams
  module Players
    class CreateForm
      include Deps[validator: 'validators.teams.players.create']

      def call(params:)
        errors = validator.call(params: params)
        return { errors: errors } if errors.any?

        teams_player = Teams::Player.create!(params)
        create_games_players(teams_player)

        { result: teams_player }
      end

      private

      def create_games_players(teams_player)
        games_players =
          teams_player
          .seasons_team
          .games.joins(:week)
          .where(games: { points: [] })
          .where(weeks: { status: %w[active coming] }).map do |game|
            {
              game_id: game.id,
              teams_player_id: teams_player.id,
              position_kind: teams_player.player.position_kind,
              seasons_team_id: teams_player.seasons_team_id
            }
          end

        Games::Player.upsert_all(games_players) if games_players.any?
      end
    end
  end
end
