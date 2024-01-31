# frozen_string_literal: true

class BannedEmailContract < ApplicationContract
  config.messages.namespace = :banned_email

  params do
    required(:value).filled(:string)
    required(:reason).filled(:string)
  end
end
