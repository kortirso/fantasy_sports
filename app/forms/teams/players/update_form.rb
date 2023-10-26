# frozen_string_literal: true

module Teams
  module Players
    class UpdateForm
      include Deps[validator: 'validators.teams.players.update']

      def call(teams_player:, params:)
        errors = validator.call(params: params)
        return { errors: errors } if errors.any?

        teams_player.update!(params)
        destroy_redundant_games_players(teams_player) if ActiveModel::Type::Boolean.new.cast(params[:active]) == false

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
    end
  end
end
