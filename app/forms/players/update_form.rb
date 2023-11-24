# frozen_string_literal: true

module Players
  class UpdateForm
    include Deps[validator: 'validators.players.create']

    def call(player:, params:)
      errors = validator.call(params: params)
      return { errors: errors } if errors.any?

      player.update!(params)
      { result: player.reload }
    end
  end
end
