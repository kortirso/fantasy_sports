# frozen_string_literal: true

module Teams
  module Players
    class UpdateForm
      include Deps[validator: 'validators.teams.players.update']

      def call(teams_player:, params:)
        errors = validator.call(params: params)
        return { errors: errors } if errors.any?

        teams_player.update!(params)
        { result: teams_player.reload }
      end
    end
  end
end
