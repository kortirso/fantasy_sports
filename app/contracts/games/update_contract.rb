# frozen_string_literal: true

module Games
  class UpdateContract < ApplicationContract
    config.messages.namespace = :game

    params do
      optional(:week_id)
      optional(:start_at)
    end
  end
end
