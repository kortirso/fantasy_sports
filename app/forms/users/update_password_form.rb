# frozen_string_literal: true

module Users
  class UpdatePasswordForm
    include Deps[validator: 'validators.users.update_password']

    def call(user:, params:)
      errors = validator.call(params: params)
      return { errors: errors } if errors.any?

      user.assign_attributes(params)
      error = validate_user(user)
      return { errors: [error] } if error.present?

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
