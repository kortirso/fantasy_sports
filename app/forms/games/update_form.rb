# frozen_string_literal: true

module Games
  class UpdateForm
    include Deps[validator: 'validators.games.update']

    def call(game:, params:)
      errors = validator.call(params: params)
      return { errors: errors } if errors.any?

      return { errors: 'Week does not exist' } if Week.find_by(id: params[:week_id]).nil?

      # commento: games.source, games.external_id, games.week_id
      game.update!(params)

      { result: game.reload }
    end
  end
end
