# frozen_string_literal: true

module Teams
  module Players
    class UpdateForm
      include Deps[validator: 'validators.teams.players.update']

      def call(teams_player:, params:)
        errors = validator.call(params: params)
        return { errors: errors } if errors.any?

        ActiveRecord::Base.transaction do
          destroy_redundant_games_players(teams_player) if to_bool(params[:active]) == false && teams_player.active
          create_games_players(teams_player) if to_bool(params[:active]) == true && !teams_player.active
          teams_player.update!(params)
        end

        { result: teams_player.reload }
      end

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

        Games::Player.upsert_all(games_players) if games_players.any?
      end

      def to_bool(value)
        ActiveModel::Type::Boolean.new.cast(value)
      end
    end
  end
end
