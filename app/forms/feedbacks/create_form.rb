# frozen_string_literal: true

module Feedbacks
  class CreateForm
    include Deps[validator: 'validators.feedback']

    def call(user:, params:)
      errors = validator.call(params: params)
      return { errors: errors } if errors.any?

      { result: user.feedbacks.create!(params) }
    end
  end
end
