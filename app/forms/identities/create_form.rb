# frozen_string_literal: true

module Identities
  class CreateForm
    include Deps[
      validator: 'validators.identity',
      update_service: 'services.persisters.users.update'
    ]

    def call(user:, params:)
      errors = validator.call(params: params)
      return { errors: errors } if errors.any?

      unless user.confirmed?
        # commento: users.confirmation_token, users.confirmed_at
        update_service.call(user: user, params: { confirmation_token: nil, confirmed_at: DateTime.now })
      end

      { result: user.identities.create!(params) }
    end
  end
end
