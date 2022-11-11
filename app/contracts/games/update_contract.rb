# frozen_string_literal: true

module Games
  class UpdateContract < ApplicationContract
    config.messages.namespace = :game

    params do
      optional(:source).filled(:string)
      optional(:external_id).filled(:string)
      required(:week_id).filled(:integer)
    end
  end
end
