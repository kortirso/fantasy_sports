# frozen_string_literal: true

module Users
  class CreateService
    prepend ApplicationService

    def initialize(
      user_validator: UserValidator
    )
      @user_validator = user_validator
    end

    def call(params:)
      validate_params(params)
      return if failure?

      validate_user(params)
      return if failure?

      @result.save
    rescue ActiveRecord::RecordNotUnique
      fail!(I18n.t('services.users.create.email_exists'))
    end

    private

    def validate_params(params)
      fails!(@user_validator.call(params: params))
    end

    def validate_user(params)
      @result = User.new(params)
      return if @result.valid?

      fail!(I18n.t('services.users.create.invalid'))
    end
  end
end
