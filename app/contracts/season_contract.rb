# frozen_string_literal: true

class SeasonContract < ApplicationContract
  config.messages.namespace = :season

  params do
    required(:name).filled(:string)
    required(:status).filled(:string)
  end
end
