# frozen_string_literal: true

module Users
  class UpdateContract < ApplicationContract
    config.messages.namespace = :user

    params do
      optional(:locale).filled(:string)
    end

    rule(:locale) do
      if I18n.available_locales.exclude?(values[:locale].to_sym)
        key.failure(I18n.t('dry_validation.errors.user.available_locales'))
      end
    end
  end
end
