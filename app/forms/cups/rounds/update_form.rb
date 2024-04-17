# frozen_string_literal: true

module Cups
  module Rounds
    class UpdateForm
      include Deps[validator: 'validators.cups.rounds.update']

      def call(cups_round:, params:)
        errors = validator.call(params: params)
        return { errors: errors } if errors.any?

        cups_round.update!(params)

        { result: cups_round.reload }
      end
    end
  end
end
