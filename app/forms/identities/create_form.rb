# frozen_string_literal: true

module Identities
  class CreateForm
    include Deps[validator: 'validators.identity']

    def call(user:, params:)
      errors = validator.call(params: params)
      return { errors: errors } if errors.any?

      { result: user.identities.create!(params) }
    end
  end
end
