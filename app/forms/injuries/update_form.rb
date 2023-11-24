# frozen_string_literal: true

module Injuries
  class UpdateForm
    include Deps[validator: 'validators.injuries.update']

    def call(injury:, params:)
      errors = validator.call(params: params)
      return { errors: errors } if errors.any?

      injury.update!(params)
      { result: injury.reload }
    end
  end
end
