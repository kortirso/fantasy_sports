# frozen_string_literal: true

module Users
  class CreateContract < ApplicationContract
    config.messages.namespace = :user

    params do
      optional(:email)
      optional(:username)
      required(:password).filled(:string)
      required(:password_confirmation).filled(:string)
    end

    rule(:email, :username) do
      key(:login).failure(:blank) if values[:email].blank? && values[:username].blank?
    end

    rule(:email) do
      if value
        unless /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.match?(value)
          key.failure(:invalid)
        end

        key.failure(I18n.t('dry_validation.errors.user.banned')) if BannedEmail.exists?(value: value)
      end
    end

    rule(:username) do
      if value && !/[\w+\-\_]+/i.match?(value)
        key.failure(:invalid)
      end
    end

    rule(:password, :password_confirmation) do
      key(:passwords).failure(:different) if values[:password] != values[:password_confirmation]
    end

    rule(:password) do
      if values[:password].size < Rails.configuration.minimum_password_length
        key.failure(
          I18n.t(
            'dry_validation.errors.user.password_length',
            length: Rails.configuration.minimum_password_length
          )
        )
      end
    end
  end
end
