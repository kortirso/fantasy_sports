# frozen_string_literal: true

module Cups
  module Rounds
    class CreateForm
      include Deps[validator: 'validators.cups.round']

      def call(cup:, params:)
        errors = validator.call(params: params)
        return { errors: errors } if errors.any?

        result = cup.cups_rounds.create!(params)

        { result: result }
      end
    end
  end
end
