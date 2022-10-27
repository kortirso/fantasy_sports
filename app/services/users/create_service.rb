# frozen_string_literal: true

module Users
  class CreateService
    prepend ApplicationService

    def initialize(user_validator: UserValidator)
      @user_validator = user_validator
    end

    def call(params:)
      return if validate_with(@user_validator, params) && failure?
      return if validate_user(params) && failure?

      @result.save
      send_email_confirmation
    rescue ActiveRecord::RecordNotUnique
      fail!(I18n.t('services.users.create.email_exists'))
    end

    private

    def validate_user(params)
      @result = User.new(params)
      return if @result.valid?

      fail!(I18n.t('services.users.create.invalid'))
    end

    def send_email_confirmation
      Users::Auth::SendEmailConfirmationJob.perform_now(id: @result.id)
    end
  end
end
