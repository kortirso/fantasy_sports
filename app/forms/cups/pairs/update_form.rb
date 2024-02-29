# frozen_string_literal: true

module Cups
  module Pairs
    class UpdateForm
      include Deps[validator: 'validators.cups.pair']

      def call(cups_pair:, params:)
        errors = validator.call(params: params)
        return { errors: errors } if errors.any?

        cups_pair.update!(params)

        { result: cups_pair.reload }
      end
    end
  end
end
