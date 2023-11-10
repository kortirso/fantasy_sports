# frozen_string_literal: true

module Users
  class UpdateForm
    include Deps[validator: 'validators.users.update']

    def call(user:, params:)
      errors = validator.call(params: params)
      return { errors: errors } if errors.any?

      user.assign_attributes(params)
      error = validate_user(user)
      return { errors: [error] } if error.present?

      # commento: users.password, users.password_confirmation
      user.save!

      { result: user.reload }
    end

    private

    def validate_user(user)
      return if user.valid?

      I18n.t('services.users.create.invalid')
    end
  end
end
