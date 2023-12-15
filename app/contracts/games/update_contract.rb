# frozen_string_literal: true

module Games
  class UpdateContract < ApplicationContract
    config.messages.namespace = :game

    params do
      required(:week_id).filled(:integer)
    end
  end
end
