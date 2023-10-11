# frozen_string_literal: true

module Players
  class CreateForm
    include Deps[validator: 'validators.players.create']

    def call(params:)
      errors = validator.call(params: params)
      return { errors: errors } if errors.any?

      { result: Player.create!(params) }
    end
  end
end
