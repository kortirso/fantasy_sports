# frozen_string_literal: true

module Teams
  module Players
    class CreateForm
      include Deps[validator: 'validators.teams.players.create']

      def call(params:)
        errors = validator.call(params: params)
        return { errors: errors } if errors.any?

        { result: Teams::Player.create!(params) }
      end
    end
  end
end
