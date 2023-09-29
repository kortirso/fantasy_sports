# frozen_string_literal: true

module Users
  class UpdateService
    prepend ApplicationService
    include Validateable

    def call(user:, params:)
      return if validate_user(user, params) && failure?

      @result.save!
    end

    private

    def validate_user(user, params)
      @result = user
      @result.assign_attributes(params)
      return if @result.valid?

      fail!(I18n.t('services.users.create.invalid'))
    end
  end
end
