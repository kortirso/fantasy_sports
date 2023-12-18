# frozen_string_literal: true

class IdentityContract < ApplicationContract
  config.messages.namespace = :identity

  params do
    required(:uid).filled(:string)
    required(:provider).filled(:string)
    required(:login).filled(:string)
    optional(:email).filled(:string)
  end
end
