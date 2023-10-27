# frozen_string_literal: true

module Teams
  module Players
    class UpdateContract < ApplicationContract
      config.messages.namespace = :teams_player

      params do
        optional(:active)
        optional(:price_cents).filled(:integer)
        optional(:shirt_number_string).filled(:string)
        optional(:form).filled(:float)
      end
    end
  end
end
