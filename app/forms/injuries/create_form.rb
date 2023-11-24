# frozen_string_literal: true

module Injuries
  class CreateForm
    include Deps[validator: 'validators.injuries.create']

    def call(params:)
      errors = validator.call(params: params)
      return { errors: errors } if errors.any?

      { result: Injury.create!(params) }
    end
  end
end
