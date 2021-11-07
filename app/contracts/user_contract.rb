# frozen_string_literal: true

class UserContract < ApplicationContract
  config.messages.namespace = :user

  schema do
    optional(:id)
    required(:email).filled(:string)
    required(:password).filled(:string)
    required(:password_confirmation).filled(:string)
  end

  rule(:email) do
    unless /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.match?(value)
      key.failure('has invalid format')
    end
  end

  rule(:password, :password_confirmation) do
    key(:passwords).failure('must be equal') if values[:password] != values[:password_confirmation]
  end

  rule(:password) do
    if values[:password].size < Rails.configuration.minimum_password_length
      key.failure("must be greater or equal #{Rails.configuration.minimum_password_length} characters")
    end
  end
end
