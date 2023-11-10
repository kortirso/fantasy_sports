# frozen_string_literal: true

module Persisters
  module Users
    class UpdateService
      def call(user:, params:)
        user.assign_attributes(params)
        error = validate_user(user)
        return { errors: [error] } if error.present?

        # commento: users.confirmation_token, users.confirmed_at
        user.save!
      end

      private

      def validate_user(user)
        return if user.valid?

        I18n.t('services.users.create.invalid')
      end
    end
  end
end
