# frozen_string_literal: true

module Cups
  module Pairs
    class CreateForm
      include Deps[validator: 'validators.cups.pair']

      def call(cups_round:, params:)
        errors = validator.call(params: params)
        return { errors: errors } if errors.any?

        result = cups_round.cups_pairs.create!(params)

        { result: result }
      end
    end
  end
end
