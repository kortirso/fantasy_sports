# frozen_string_literal: true

module Teams
  module Players
    class UpdateForm
      include Deps[
        validator: 'validators.teams.players.update',
        to_bool: 'to_bool'
      ]

      # rubocop: disable Metrics/AbcSize
      def call(teams_player:, params:)
        errors = validator.call(params: params)
        return { errors: errors } if errors.any?

        ActiveRecord::Base.transaction do
          unless params[:active].nil?
            active_change = to_bool.call(params[:active])

            destroy_redundant_games_players(teams_player) if active_change == false && teams_player.active
            create_games_players(teams_player) if active_change == true && !teams_player.active
          end
          teams_player.update!(params)
        end

        { result: teams_player.reload }
      end
      # rubocop: enable Metrics/AbcSize

      private

      def destroy_redundant_games_players(teams_player)
        teams_player
          .games_players
          .joins(game: :week)
          .where(games: { points: [] })
          .where(weeks: { status: %w[active coming] })
          .destroy_all
      end

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

        # commento: games_players.position_kind
        Games::Player.upsert_all(games_players) if games_players.any?
      end
    end
  end
end
