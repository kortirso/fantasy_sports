# frozen_string_literal: true

module BannedEmails
  class CreateForm
    include Deps[
      validator: 'validators.banned_email',
      update_service: 'services.persisters.users.update'
    ]

    def call(params:)
      errors = validator.call(params: params)
      return { errors: errors } if errors.any?

      user = User.find_by(email: params[:value])
      # commento: users.banned_at
      update_service.call(user: user, params: { banned_at: DateTime.now }) if user

      { result: BannedEmail.create!(params) }
    end
  end
end
