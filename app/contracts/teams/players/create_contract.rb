# frozen_string_literal: true

module Teams
  module Players
    class CreateContract < ApplicationContract
      config.messages.namespace = :teams_player

      params do
        required(:price_cents).filled(:integer)
        required(:shirt_number).filled(:integer)
        required(:form).filled(:float)
      end
    end
  end
end