# frozen_string_literal: true

module Users
  class CreateForm
    include Deps[validator: 'validators.users.create']

    def call(params:, with_send_confirmation: true)
      errors = validator.call(params: params)
      return { errors: errors } if errors.any?

      user = User.new(params)
      error = validate_user(user)
      return { errors: [error] } if error.present?

      send_email_confirmation(user) if user.save && user.email.present? && with_send_confirmation

      { result: user }
    rescue ActiveRecord::RecordNotUnique
      { errors: [I18n.t('services.users.create.not_unique')] }
    end

    private

    def validate_user(user)
      return if user.valid?

      I18n.t('services.users.create.invalid')
    end

    def send_email_confirmation(user)
      Users::Auth::SendEmailConfirmationJob.perform_now(id: user.id)
    end
  end
end
